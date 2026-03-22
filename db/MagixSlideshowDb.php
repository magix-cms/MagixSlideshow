<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow\db;

use App\Backend\Db\BaseDb;
use Magepattern\Component\Database\QueryBuilder;

class MagixSlideshowDb extends BaseDb
{
    // ==========================================
    // GESTION DES SLIDES
    // ==========================================

    /**
     * Récupère la liste des slides pour le tableau de bord
     */
    public function getSlidesList(int $idLang): array
    {
        $qb = new QueryBuilder();
        $qb->select(['s.id_slide', 's.img_slide', 's.order_slide', 's.date_register', 'sc.title_slide', 'sc.published_slide'])
            ->from('mc_magixslideshow', 's')
            ->leftJoin('mc_magixslideshow_content', 'sc', 's.id_slide = sc.id_slide AND sc.id_lang = ' . $idLang)
            ->orderBy('s.order_slide', 'ASC');

        return $this->executeAll($qb) ?: [];
    }

    /**
     * Supprime un slide
     */
    public function deleteSlide(int $idSlide): bool
    {
        $qb = new QueryBuilder();
        $qb->delete('mc_magixslideshow')->where('id_slide = :id', ['id' => $idSlide]);
        return $this->executeDelete($qb);
    }

    /**
     * Met à jour uniquement le nom de l'image d'un slide après l'upload
     */
    public function updateSlideImage(int $idSlide, string $imageName): bool
    {
        $qb = new QueryBuilder();
        $qb->update('mc_magixslideshow', ['img_slide' => $imageName])
            ->where('id_slide = :id', ['id' => $idSlide]);

        return $this->executeUpdate($qb);
    }

    /**
     * Sauvegarde ou insère un slide et ses traductions
     */
    public function saveSlide(int $idSlide, array $mainData, array $contentData): int
    {
        // 1. Mise à jour ou insertion de la base du slide
        $qbMain = new QueryBuilder();

        if ($idSlide > 0) {
            // Si on a des données principales à mettre à jour (ex: l'ordre)
            if (!empty($mainData)) {
                $qbMain->update('mc_magixslideshow', $mainData)->where('id_slide = :id', ['id' => $idSlide]);
                $this->executeUpdate($qbMain);
            }
        } else {
            // INSERTION : On calcule le prochain ordre disponible
            $qbOrder = new QueryBuilder();
            $qbOrder->select('MAX(order_slide) as max_order')->from('mc_magixslideshow');
            $res = $this->executeRow($qbOrder);
            $order = $res ? (int)$res['max_order'] + 1 : 1;

            $mainData['order_slide'] = $order;
            if (!isset($mainData['img_slide'])) {
                $mainData['img_slide'] = '';
            }

            $qbMain->insert('mc_magixslideshow', $mainData);
            if ($this->executeInsert($qbMain)) {
                $idSlide = $this->getLastInsertId();
            } else {
                return 0; // Échec de l'insertion
            }
        }

        // 2. Gestion des traductions
        foreach ($contentData as $idLang => $data) {
            $qbCheck = new QueryBuilder();
            $qbCheck->select('id_slide_content')->from('mc_magixslideshow_content')
                ->where('id_slide = :id AND id_lang = :lang', ['id' => $idSlide, 'lang' => $idLang]);

            if ($this->executeRow($qbCheck)) {
                $qbUp = new QueryBuilder();
                $qbUp->update('mc_magixslideshow_content', $data)
                    ->where('id_slide = :id AND id_lang = :lang', ['id' => $idSlide, 'lang' => $idLang]);
                $this->executeUpdate($qbUp);
            } else {
                $data['id_slide'] = $idSlide;
                $data['id_lang']  = $idLang;
                $qbIn = new QueryBuilder();
                $qbIn->insert('mc_magixslideshow_content', $data);
                $this->executeInsert($qbIn);
            }
        }

        return $idSlide;
    }

    /**
     * Récupère un slide complet avec toutes ses traductions (pour l'édition AJAX)
     */
    public function getSlideFull(int $idSlide): array
    {
        // 1. Infos principales
        $qbMain = new QueryBuilder();
        $qbMain->select('*')->from('mc_magixslideshow')->where('id_slide = :id', ['id' => $idSlide]);
        $slide = $this->executeRow($qbMain);

        if (!$slide) {
            return [];
        }

        // 2. Traductions
        $qbLang = new QueryBuilder();
        $qbLang->select('*')->from('mc_magixslideshow_content')->where('id_slide = :id', ['id' => $idSlide]);
        $langs = $this->executeAll($qbLang);

        $slide['content'] = [];
        if ($langs) {
            foreach ($langs as $l) {
                // On indexe par ID de langue pour que le JS/Smarty s'y retrouve facilement
                $slide['content'][$l['id_lang']] = $l;
            }
        }

        return $slide;
    }
    /**
     * Met à jour l'ordre d'un slide
     */
    /**
     * Met à jour l'ordre d'un slide
     */
    public function updateSlideOrder(int $idSlide, int $position): bool
    {
        $qb = new QueryBuilder();
        $qb->update('mc_magixslideshow', ['order_slide' => $position])
            ->where('id_slide = :id', ['id' => $idSlide]);

        return $this->executeUpdate($qb);
    }
}