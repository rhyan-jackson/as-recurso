import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log('Modal controller connected')
    
    // Listen to turbo frame load
    this.element.addEventListener('turbo:frame-load', (e) => {
      console.log('turbo:frame-load fired', e)
      this.open()
    })
  }

  open() {
    if (this.modalTarget.hasAttribute("open")) {
      return
    }
    
    // Show the modal
    this.modalTarget.showModal()
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
    
    // Animação: adiciona classe após o modal estar visível
    const modalContent = this.modalTarget.querySelector('.modal-content')
    if (modalContent) {
      modalContent.classList.remove('modal-animate-in')
      setTimeout(() => {
        modalContent.classList.add('modal-animate-in')
      }, 10)
    }
    
    // Focus management
    const firstFocusable = this.modalTarget.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    if (firstFocusable) {
      firstFocusable.focus()
    }
  }

  close() {
    // Remove animação antes de fechar
    const modalContent = this.modalTarget.querySelector('.modal-content')
    if (modalContent) {
      modalContent.classList.remove('modal-animate-in')
    }
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

  lightDismiss(e) {
    if (e.target === this.modalTarget) {
      this.close()
    }
  }

  keydown(e) {
    if (e.key === "Escape") {
      this.close()
    }
  }

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