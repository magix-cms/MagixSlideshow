<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow\src;

use Plugins\MagixSlideshow\db\MagixSlideshowFrontDb;
use App\Component\File\ImageTool;
use Magepattern\Component\Tool\SmartyTool;
use Detection\MobileDetect;; // 🟢 Ajout de MobileDetect (Ajustez le namespace si vous utilisez la v4)

class FrontendController
{
    public static function renderWidget(array $params = []): string
    {
        $currentLang = $params['current_lang'] ?? ['id_lang' => 1, 'iso_lang' => 'fr'];
        $idLang = (int)$currentLang['id_lang'];

        $db = new MagixSlideshowFrontDb();
        $activeSlides = $db->getSlidesList($idLang);

        if (empty($activeSlides)) {
            return '';
        }

        // 🟢 1. Détection du type d'appareil
        // On instancie la nouvelle version
        $detect = new MobileDetect();

        // Détermination de la taille
        $imageSize = 'large';
        if ($detect->isMobile() && !$detect->isTablet()) {
            $imageSize = 'small';
        } elseif ($detect->isTablet()) {
            $imageSize = 'medium';
        }
        $imageTool = new ImageTool();
        $formattedSlides = [];

        foreach ($activeSlides as $slide) {
            if (empty($slide['img_slide'])) continue;

            $slide['name_img'] = $slide['img_slide'];
            $customBaseDir = '/upload/magixslideshow/' . $slide['id_slide'] . '/';

            $processed = $imageTool->setModuleImages('magixslideshow', 'magixslideshow', [$slide], 0, $customBaseDir);

            if (!empty($processed[0])) {
                $formattedSlides[] = $processed[0];
            }
        }

        if (empty($formattedSlides)) {
            return '';
        }

        $view = SmartyTool::getInstance('front');
        $view->assign([
            'slideshow_items'   => $formattedSlides,
            'device_image_size' => $imageSize
        ]);

        return $view->fetch(ROOT_DIR . 'plugins/MagixSlideshow/views/front/widget.tpl');
    }
}