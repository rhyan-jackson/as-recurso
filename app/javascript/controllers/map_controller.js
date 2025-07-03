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
    this.reservationId = urlParams.get('reservation_id') // ADD THIS LINE
    
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
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 20
    }).addTo(map)
    
    this.stationsValue.forEach(station => {
      const isAvailable = station.available_bikes > 0
      const isOriginStation = station.id.toString() === this.originStationId
      const isActiveRideOrigin = this.hasActiveRide && this.activeRideValue && station.id.toString() === this.activeRideValue.origin_station_id?.toString()
      const hasUserReservation = station.has_user_reservation // ADD THIS LINE
      
      // Different styling based on mode - UPDATED THIS BLOCK
      let color, markerText
      if (this.mode === 'end_ride') {
        if (isActiveRideOrigin) {
          color = "blue"
          markerText = "🚴‍♀️"
        } else {
          color = "orange"
          markerText = "🏁"
        }
      } else if (this.mode === 'select_destination') {
        if (isOriginStation) {
          color = "blue"
          markerText = "📍"
        } else {
          color = "green"
          markerText = "🎯"
        }
      } else {
        // Normal mode - show reservation icon if user has reservation here
        if (hasUserReservation) {
          color = "purple"
          markerText = "🎫"
        } else {
          color = isAvailable ? "green" : "red"
          markerText = station.available_bikes
        }
      }
      
      const markerIcon = L.divIcon({
        className: 'bike-station-marker',
        html: `<div style="background-color: ${color}; width: 25px; height: 25px; border-radius: 50%; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">${markerText}</div>`,
        iconSize: [31, 31],
        iconAnchor: [15, 15]
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
          // Open confirmation modal - UPDATED TO INCLUDE reservation_id
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
  
  showStepIndicator() {
    const indicator = document.getElementById('step-indicator')
    const content = document.getElementById('step-content')
    
    if (indicator && content) {
      if (this.mode === 'select_destination') {
        // UPDATE THIS TO SHOW DIFFERENT MESSAGE FOR RESERVATIONS
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