import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { stations: Array }

  connect() {
    const map = L.map(this.element, { zoomControl: false }).setView([40.6374, -8.64833], 14)
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 20
    }).addTo(map)

    this.stationsValue.forEach(station => {
      const isAvailable = station.available_bikes > 0
      const color = isAvailable ? "green" : "red"
      
      const markerIcon = L.divIcon({
        className: 'bike-station-marker',
        html: `<div style="background-color: ${color}; width: 25px; height: 25px; border-radius: 50%; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">${station.available_bikes}</div>`,
        iconSize: [31, 31],
        iconAnchor: [15, 15]
      })
      
      const marker = L.marker([station.latitude, station.longitude], { icon: markerIcon }).addTo(map)

      marker.on("click", () => {
        // Use turbo frame to load station details in modal
        const modalFrame = document.querySelector("turbo-frame#modal-content")
        if (modalFrame) {
          modalFrame.src = `/stations/${station.id}?modal=true`
        }
      })
    })
  }
}