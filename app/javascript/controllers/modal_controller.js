import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open() {
    if (this.modalTarget.hasAttribute("open")) {
      return
    }
    
    this.modalTarget.showModal()
    document.body.style.overflow = "hidden"
    
    // Focus management - focus the first focusable element or the close button
    const firstFocusable = this.modalTarget.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    if (firstFocusable) {
      firstFocusable.focus()
    }
  }

  close() {
    this.modalTarget.close()
    document.body.style.overflow = "auto"

    this.modalTarget.querySelector('turbo-frame').innerHTML = ""
  }

  afterSubmit(e) {
    const success = e.detail.fetchResponse?.response?.headers.get("X-Turbo-Modal-Close")
    if (success === "true") {
      this.close()
    }
  }

  // Handle clicking on backdrop (the ::backdrop pseudo-element)
  lightDismiss(e) {
    if (e.target === this.modalTarget) {
      this.close()
    }
  }

  // Handle Escape key (this is automatic with dialog, but you can customize)
  keydown(e) {
    if (e.key === "Escape") {
      this.close()
    }
  }

  // Trap focus within the modal
  trapFocus(e) {
    if (e.key === "Tab") {
      const focusableElements = this.modalTarget.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      )
      
      const firstFocusable = focusableElements[0]
      const lastFocusable = focusableElements[focusableElements.length - 1]

      if (e.shiftKey) {
        if (document.activeElement === firstFocusable) {
          lastFocusable.focus()
          e.preventDefault()
        }
      } else {
        if (document.activeElement === lastFocusable) {
          firstFocusable.focus()
          e.preventDefault()
        }
      }
    }
  }
}