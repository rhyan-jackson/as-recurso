import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { stations: Array, activeRide: Object }
  
  connect() {
    // Safety check for stations data
    if (!this.hasStationsValue || !Array.isArray(this.stationsValue) || this.stationsValue.length === 0) {
      console.error('No valid stations data found')
      return
    }
    
    // Check mode - could be normal, select_destination, or end_ride
    const urlParams = new URLSearchParams(window.location.search)
    this.mode = urlParams.get('mode') || 'normal'
    this.originStationId = urlParams.get('origin')
    this.selectedBrand = urlParams.get('brand')
    this.reservationId = urlParams.get('reservation_id')
    
    // Determine map mode
    this.hasActiveRide = this.hasActiveRideValue && this.activeRideValue && Object.keys(this.activeRideValue).length > 0
    if (this.hasActiveRide) {
      if (this.mode === 'normal') {
        this.mode = 'end_ride'
      }
    }
    
    // Show step indicator if needed
    this.showStepIndicator()
    
    const map = L.map(this.element, { zoomControl: false }).setView([40.6374, -8.64833], 14)
    
    // Updated to use Carto Light style
    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
      attribution: '© OpenStreetMap contributors, © CARTO',
      subdomains: 'abcd',
      maxZoom: 20
    }).addTo(map)
    
    // Add fake user location around Aveiro
    this.addFakeUserLocation(map)
    
    this.stationsValue.forEach(station => {
      const isAvailable = station.available_bikes > 0
      const isOriginStation = station.id.toString() === this.originStationId
      const isActiveRideOrigin = this.hasActiveRide && this.activeRideValue && station.id.toString() === this.activeRideValue.origin_station_id?.toString()
      const hasUserReservation = station.has_user_reservation
      
      // Modern icons and styling based on mode
      let color, icon, textColor = 'white'
      if (this.mode === 'end_ride') {
        if (isActiveRideOrigin) {
          color = "#2563eb" // Blue-600
          icon = "🚴‍♀️"
        } else {
          color = "#ea580c" // Orange-600
          icon = "🏁"
        }
      } else if (this.mode === 'select_destination') {
        if (isOriginStation) {
          color = "#2563eb" // Blue-600
          icon = "📍"
        } else {
          color = "#16a34a" // Green-600
          icon = "🎯"
        }
      } else {
        // Normal mode - show reservation icon if user has reservation here
        if (hasUserReservation) {
          color = "#9333ea" // Purple-600
          icon = "🎫"
        } else {
          color = isAvailable ? "#16a34a" : "#dc2626" // Green-600 : Red-600
          icon = station.available_bikes
          textColor = 'white'
        }
      }
      
      // Modern marker design with better shadows and styling
      const markerIcon = L.divIcon({
        className: 'bike-station-marker',
        html: `
          <div style="
            background: linear-gradient(135deg, ${color} 0%, ${this.darkenColor(color, 0.1)} 100%);
            width: 32px; 
            height: 32px; 
            border-radius: 50%; 
            border: 2px solid white; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            color: ${textColor}; 
            font-weight: 600; 
            font-size: ${typeof icon === 'number' ? '11px' : '14px'}; 
            box-shadow: 0 4px 12px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.1);
            transition: all 0.2s ease;
            cursor: pointer;
          " 
          onmouseover="this.style.transform='scale(1.1)'; this.style.boxShadow='0 6px 20px rgba(0,0,0,0.2), 0 4px 8px rgba(0,0,0,0.15)'"
          onmouseout="this.style.transform='scale(1)'; this.style.boxShadow='0 4px 12px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.1)'"
          >${icon}</div>
        `,
        iconSize: [36, 36],
        iconAnchor: [18, 18]
      })
      
      const marker = L.marker([station.latitude, station.longitude], { icon: markerIcon }).addTo(map)
      
      marker.on("click", () => {
        if (this.mode === 'end_ride' && !isActiveRideOrigin) {
          console.log('End ride at station:', station.name)
          // Open end ride confirmation modal
          const modalFrame = document.querySelector("turbo-frame#modal-content")
          if (modalFrame) {
            modalFrame.src = `/rides/${this.activeRideValue.id}/end_confirm?station_id=${station.id}`
          }
        } else if (this.mode === 'select_destination' && !isOriginStation) {
          console.log('Selected destination:', station.name)
          // Open confirmation modal
          const modalFrame = document.querySelector("turbo-frame#modal-content")
          if (modalFrame) {
            let confirmUrl = `/rides/start_confirm?origin=${this.originStationId}&destination=${station.id}&brand=${this.selectedBrand}`
            
            // Add reservation_id if it exists
            if (this.reservationId) {
              confirmUrl += `&reservation_id=${this.reservationId}`
            }
            
            modalFrame.src = confirmUrl
          }
        } else if (this.mode === 'normal') {
          const modalFrame = document.querySelector("turbo-frame#modal-content")
          if (modalFrame) {
            modalFrame.src = `/stations/${station.id}?modal=true`
          }
        }
      })
    })
  }
  
  addFakeUserLocation(map) {
    // Check if we have a stored location for this user
    const storedLocation = localStorage.getItem('userLocation')
    let userLat, userLng
    
    if (storedLocation) {
      // Use stored location
      const location = JSON.parse(storedLocation)
      userLat = location.lat
      userLng = location.lng
    } else {
      // Generate a new random location around Aveiro city center
      // Aveiro center coordinates: 40.6374, -8.64833
      const baseLatitude = 40.6374
      const baseLongitude = -8.64833
      
      // Add small random offset (roughly within 2km radius)
      const latOffset = (Math.random() - 0.5) * 0.02 // ~1km in latitude
      const lngOffset = (Math.random() - 0.5) * 0.03 // ~1km in longitude (adjusted for latitude)
      
      userLat = baseLatitude + latOffset
      userLng = baseLongitude + lngOffset
      
      // Check if location is too close to any station
      const minDistance = 0.0005 // Roughly 50 meters
      let tooClose = false
      
      do {
        tooClose = false
        for (const station of this.stationsValue) {
          const distance = Math.sqrt(
            Math.pow(userLat - station.latitude, 2) + 
            Math.pow(userLng - station.longitude, 2)
          )
          
          if (distance < minDistance) {
            // Generate new location
            userLat = baseLatitude + (Math.random() - 0.5) * 0.02
            userLng = baseLongitude + (Math.random() - 0.5) * 0.03
            tooClose = true
            break
          }
        }
      } while (tooClose)
      
      // Store the new location
      localStorage.setItem('userLocation', JSON.stringify({
        lat: userLat,
        lng: userLng,
        timestamp: Date.now()
      }))
    }
    
    // Create user location marker
    const userLocationIcon = L.divIcon({
      className: 'user-location-marker',
      html: `
        <div style="
          background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
          width: 20px; 
          height: 20px; 
          border-radius: 50%; 
          border: 3px solid white; 
          box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4), 0 2px 4px rgba(0,0,0,0.1);
          position: relative;
          z-index: 1000;
        ">
          <div style="
            background: #3b82f6;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            opacity: 0.2;
            position: absolute;
            top: -13px;
            left: -13px;
            animation: pulse 2s infinite;
          "></div>
        </div>
        <style>
          @keyframes pulse {
            0% {
              transform: scale(0.5);
              opacity: 0.2;
            }
            50% {
              transform: scale(1);
              opacity: 0.1;
            }
            100% {
              transform: scale(1.2);
              opacity: 0;
            }
          }
        </style>
      `,
      iconSize: [20, 20],
      iconAnchor: [10, 10]
    })
    
    const userMarker = L.marker([userLat, userLng], { 
      icon: userLocationIcon,
      zIndexOffset: 1000 // Ensure user location appears above stations
    }).addTo(map)
    
    // Store marker reference for potential future updates
    this.userMarker = userMarker
    this.userLocation = { lat: userLat, lng: userLng }
  }
  
  // Helper function to darken colors for gradient effect
  darkenColor(color, amount) {
    const usePound = color[0] === '#'
    const col = usePound ? color.slice(1) : color
    const num = parseInt(col, 16)
    let r = (num >> 16) + amount
    let g = (num >> 8 & 0x00FF) + amount
    let b = (num & 0x0000FF) + amount
    r = r > 255 ? 255 : r < 0 ? 0 : r
    g = g > 255 ? 255 : g < 0 ? 0 : g
    b = b > 255 ? 255 : b < 0 ? 0 : b
    return (usePound ? '#' : '') + (r << 16 | g << 8 | b).toString(16)
  }
  
  showStepIndicator() {
    const indicator = document.getElementById('step-indicator')
    const content = document.getElementById('step-content')
    
    if (indicator && content) {
      if (this.mode === 'select_destination') {
        const message = this.reservationId 
          ? `<strong>Passo 2:</strong> Selecione o destino para a sua reserva de ${this.selectedBrand}`
          : `<strong>Passo 2:</strong> Selecione a estação de destino`
        
        content.innerHTML = message
        indicator.style.display = 'block'
      } else if (this.mode === 'end_ride' && this.hasActiveRide) {
        content.innerHTML = `<strong>Terminar Viagem:</strong> Selecione onde quer deixar a bicicleta ${this.activeRideValue.bike_brand} #${this.activeRideValue.bike_id}`
        indicator.style.display = 'block'
      } else {
        indicator.style.display = 'none'
      }
    }
  }
}