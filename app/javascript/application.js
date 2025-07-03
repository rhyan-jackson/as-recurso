// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Bootstrap
import "bootstrap"

// Make Bootstrap available globally
window.bootstrap = bootstrap

// Initialize all Bootstrap tooltips and popovers
document.addEventListener("turbo:load", () => {
  // Initialize tooltips everywhere
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.map((tooltipTriggerEl) => {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Initialize popovers everywhere
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  popoverTriggerList.map((popoverTriggerEl) => {
    return new bootstrap.Popover(popoverTriggerEl)
  })
})
