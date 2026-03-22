<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow\db;

use App\Frontend\Db\BaseDb; // 🟢 On utilise la classe de base du FRONTEND
use Magepattern\Component\Database\QueryBuilder;

class MagixSlideshowFrontDb extends BaseDb
{
    /**
     * Récupère la liste des slides publiés pour le Frontend
     */
    public function getSlidesList(int $idLang): array
    {
        $qb = new QueryBuilder();
        $qb->select(['s.id_slide', 's.img_slide', 'sc.title_slide', 'sc.desc_slide', 'sc.link_url_slide', 'sc.link_label_slide', 'sc.link_title_slide', 'sc.blank_slide', 'sc.published_slide'])
            ->from('mc_magixslideshow', 's')
            ->leftJoin('mc_magixslideshow_content', 'sc', 's.id_slide = sc.id_slide AND sc.id_lang = ' . $idLang)
            ->where('sc.published_slide = 1') // On filtre directement en SQL, c'est plus performant !
            ->orderBy('s.order_slide', 'ASC');

        return $this->executeAll($qb) ?: [];
    }
}