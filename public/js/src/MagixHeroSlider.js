/**
 * Magix Hero Slider
 * Initialise le diaporama Splide uniquement si l'élément cible existe dans le DOM.
 */
class MagixHeroSlider {
    constructor(elementId) {
        this.sliderElement = document.getElementById(elementId);

        // Sécurité : on s'arrête immédiatement si l'élément n'existe pas ou si Splide n'est pas chargé
        if (!this.sliderElement || typeof Splide === 'undefined') {
            return;
        }

        this.init();
    }

    init() {
        const heroSlider = new Splide(this.sliderElement, {
            type: 'fade',
            rewind: true,
            autoplay: true,
            interval: 6000,
            pauseOnHover: false,
            arrows: false,
            pagination: false,
            speed: 1000
        });
        
        requestAnimationFrame(() => {
            heroSlider.mount();
        });
    }
}

// Initialisation au chargement du DOM
document.addEventListener('DOMContentLoaded', () => {
    new MagixHeroSlider('magix-hero-slideshow');
});