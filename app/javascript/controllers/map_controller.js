import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { stations: Array }
  
  connect() {
    // Safety check for stations data
    if (!this.hasStationsValue || !Array.isArray(this.stationsValue) || this.stationsValue.length === 0) {
      console.error('No valid stations data found')
      return
    }
    
    // Check if we're in destination selection mode
    const urlParams = new URLSearchParams(window.location.search)
    this.mode = urlParams.get('mode') || 'normal'
    this.originStationId = urlParams.get('origin')
    this.selectedBrand = urlParams.get('brand')
    
    console.log('Map mode:', this.mode)
    
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
      
      // Different styling based on mode
      let color, markerText
      if (this.mode === 'select_destination') {
        if (isOriginStation) {
          color = "blue"
          markerText = "📍"
        } else {
          color = "green"
          markerText = "🎯"
        }
      } else {
        color = isAvailable ? "green" : "red"
        markerText = station.available_bikes
      }
      
      const markerIcon = L.divIcon({
        className: 'bike-station-marker',
        html: `<div style="background-color: ${color}; width: 25px; height: 25px; border-radius: 50%; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">${markerText}</div>`,
        iconSize: [31, 31],
        iconAnchor: [15, 15]
      })
      
      const marker = L.marker([station.latitude, station.longitude], { icon: markerIcon }).addTo(map)
      
      marker.on("click", () => {
        if (this.mode === 'select_destination' && !isOriginStation) {
          console.log('Selected destination:', station.name)
          // Open confirmation modal
          const modalFrame = document.querySelector("turbo-frame#modal-content")
          if (modalFrame) {
            modalFrame.src = `/rides/confirm?origin=${this.originStationId}&destination=${station.id}&brand=${this.selectedBrand}`
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
    
    if (this.mode === 'select_destination' && indicator && content) {
      content.innerHTML = `Selecione a estação de destino`
      indicator.style.display = 'block'
    }
  }
}