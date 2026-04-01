<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow;

use App\Component\Hook\HookManager;

class Boot
{
    public function register(): void
    {
        // On accroche le Slideshow tout en haut de la page d'accueil
        /*HookManager::register(
            'displayHomeTop',
            'MagixSlideshow',
            [\Plugins\MagixSlideshow\src\FrontendController::class, 'renderWidget']
        );*/
    }
}