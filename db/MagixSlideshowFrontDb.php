<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow\db;

use App\Frontend\Db\BaseDb;
use Magepattern\Component\Database\QueryBuilder;

class MagixSlideshowFrontDb extends BaseDb
{
    /**
     * Récupère la liste des slides publiés pour le Frontend (Avec Cache SQL)
     */
    public function getSlidesList(int $idLang): array
    {
        // 🟢 1. Instanciation du gestionnaire de cache SQL
        $cache = $this->getSqlCache();
        $qb = new QueryBuilder();

        $qb->select([
            's.id_slide', 's.img_slide',
            'sc.title_slide', 'sc.desc_slide',
            // Bouton 1
            'sc.link_url_slide', 'sc.link_label_slide', 'sc.link_title_slide', 'sc.blank_slide',
            // Bouton 2
            'sc.link2_url_slide', 'sc.link2_label_slide', 'sc.link2_title_slide', 'sc.blank2_slide',
            // Statut
            'sc.published_slide'
        ])
            ->from('mc_magixslideshow', 's')
            ->leftJoin('mc_magixslideshow_content', 'sc', 's.id_slide = sc.id_slide AND sc.id_lang = ' . $idLang)
            ->where('sc.published_slide = 1')
            ->orderBy('s.order_slide', 'ASC');

        // 🟢 2. Génération de la clé de cache avec le Tag unique du plugin
        $cacheKey = $cache->generateKey($qb->getSql(), $qb->getParams(), 'magixslideshow');

        // 🟢 3. Vérification : Les données sont-elles déjà en cache ?
        $data = $cache->get($cacheKey);
        if ($data !== null) {
            return $data; // On retourne le cache direct (0 requête SQL !)
        }

        // 🟢 4. Si le cache est vide, on interroge la base de données
        $res = $this->executeAll($qb) ?: [];

        // 🟢 5. On met le résultat en cache pour 24 heures (86400 secondes)
        $cache->set($cacheKey, $res, 86400);

        return $res;
    }
}