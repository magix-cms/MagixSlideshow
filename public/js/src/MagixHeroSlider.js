/**
 * Magix Hero Slider
 * Initialisation immédiate pour optimiser la métrique LCP (Largest Contentful Paint).
 */
class MagixHeroSlider {
    constructor(elementId) {
        this.sliderElement = document.getElementById(elementId);

        // Sécurité : arrêt immédiat si l'élément n'existe pas ou si la librairie est absente
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

        // OPTIMISATION LCP : On monte le slider instantanément, sans aucun délai.
        heroSlider.mount();
    }
}

// Initialisation dès que l'arbre DOM est prêt
document.addEventListener('DOMContentLoaded', () => {
    new MagixHeroSlider('magix-hero-slideshow');
});