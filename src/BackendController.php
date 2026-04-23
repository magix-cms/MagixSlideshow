<?php

declare(strict_types=1);

namespace Plugins\MagixSlideshow\src;

use App\Backend\Controller\BaseController;
use Plugins\MagixSlideshow\db\MagixSlideshowDb;
use Magepattern\Component\HTTP\Request;
use Magepattern\Component\Tool\FormTool;
use Magepattern\Component\Tool\SmartyTool;
use App\Component\File\UploadTool;
use App\Component\File\ImageTool;
use Magepattern\Component\File\FileTool;
use Magepattern\Component\HTTP\Url;

class BackendController extends BaseController
{
    public function run(): void
    {
        SmartyTool::addTemplateDir('admin', ROOT_DIR . 'plugins' . DS . 'MagixSlideshow' . DS . 'views' . DS . 'admin');

        $action = $_GET['action'] ?? null;

        // 🟢 INTERCEPTION : table-forms.tpl utilise '?edit=ID' pour les boutons de modification
        if (isset($_GET['edit'])) {
            $action = 'edit';
        }

        // Mini-routeur
        if ($action && $action !== 'run' && method_exists($this, $action)) {
            $this->$action();
            return;
        }

        $this->index();
    }

    /**
     * Affiche la liste des slides (Géré par table-forms.tpl)
     */
    public function index(): void
    {
        $db = new MagixSlideshowDb();
        $idLangue = (int)($this->defaultLang['id_lang'] ?? 1);
        $langs = $db->fetchLanguages();

        // 1. Schéma pour table-forms
        $targetColumns = ['id_slide', 'order_slide', 'title_slide', /*'img_slide', */'published_slide', 'date_register'];

        $rawScheme = array_merge(
            $db->getTableScheme('mc_magixslideshow'),
            $db->getTableScheme('mc_magixslideshow_content')
        );

        $associations = [
            'id_slide'        => ['title' => 'id', 'type' => 'text', 'class' => 'text-center text-muted small px-2'],
            'order_slide'     => ['title' => 'ordre', 'type' => 'text', 'class' => 'text-muted fw-bold'],
            'title_slide'     => ['title' => 'name', 'type' => 'text', 'class' => 'w-50 fw-bold'],
            //'img_slide'       => ['title' => 'image', 'type' => 'bin', 'class' => 'text-center px-3', 'enum' => 'image_'],
            'published_slide' => ['title' => 'published', 'type' => 'bin', 'class' => 'text-center px-3', 'enum' => 'published_'],
            'date_register'   => ['title' => 'date', 'type' => 'date', 'class' => 'text-center text-nowrap text-muted small']
        ];

        $this->getScheme($rawScheme, $targetColumns, $associations);

        // 2. Récupération et formatage des images
        $rawSlidesList = $db->getSlidesList($idLangue);
        $imageTool = new ImageTool();
        $slidesListForImageTool = [];

        foreach ($rawSlidesList as $slide) {
            $slide['name_img'] = $slide['img_slide'];
            $slidesListForImageTool[] = $slide;
        }

        $formattedSlidesList = [];
        foreach ($slidesListForImageTool as $slide) {
            $customBaseDir = '/upload/magixslideshow/' . $slide['id_slide'] . '/';
            $processed = $imageTool->setModuleImages('magixslideshow', 'magixslideshow', [$slide], 0, $customBaseDir);
            $formattedSlidesList[] = $processed[0];
        }

        $this->getItems('slidesList', $formattedSlidesList, true);

        // 3. Variables Smarty
        $token = $this->session->getToken();
        $this->view->assign([
            'langs'       => $langs,
            'langIdsJson' => json_encode(array_keys($langs)),
            'slidesList'  => $formattedSlidesList,
            'defaultLang' => $this->defaultLang,
            'idcolumn'    => 'id_slide',
            'hashtoken'   => $token,
            'url_token'   => urlencode($token),
            'sortable'    => true,
            'checkbox'    => true,
            'edit'        => true,
            'dlt'         => true
        ]);

        $this->view->display('index.tpl');
    }

    /**
     * Affiche la page d'ajout d'un slide vierge
     */
    public function add(): void
    {
        $db = new MagixSlideshowDb();

        $this->view->assign([
            'langs'     => $db->fetchLanguages(),
            'hashtoken' => $this->session->getToken(),
            'slide'     => ['id_slide' => 0, 'content' => []]
        ]);

        $this->view->display('form.tpl');
    }

    /**
     * Affiche la page d'édition avec les données du slide
     */
    /**
     * Affiche la page d'édition avec les données du slide
     */
    public function edit(): void
    {
        $idSlide = (int)($_GET['edit'] ?? 0);
        $db = new MagixSlideshowDb();

        $data = $db->getSlideFull($idSlide);

        if (empty($data)) {
            header('Location: index.php?controller=MagixSlideshow');
            exit;
        }

        // 🟢 NOUVEAU : Traitement de l'image pour avoir la miniature dans le formulaire
        if (!empty($data['img_slide'])) {
            $imageTool = new ImageTool();
            $data['name_img'] = $data['img_slide']; // Nécessaire pour ImageTool
            $customBaseDir = '/upload/magixslideshow/' . $data['id_slide'] . '/';

            $processed = $imageTool->setModuleImages('magixslideshow', 'magixslideshow', [$data], 0, $customBaseDir);

            if (!empty($processed[0])) {
                $data = $processed[0]; // Écrase $data avec le tableau contenant $data['img']['small']...
            }
        }

        $this->view->assign([
            'langs'     => $db->fetchLanguages(),
            'hashtoken' => $this->session->getToken(),
            'slide'     => $data
        ]);

        $this->view->display('form.tpl');
    }

    /**
     * Sauvegarde du formulaire (Image + Contenu) via validate_form
     */
    public function saveSlide(): void
    {
        if (!Request::isMethod('POST')) return;

        $token = $_POST['hashtoken'] ?? '';
        if (!$this->session->validateToken($token)) {
            $this->jsonResponse(false, 'Session expirée.');
        }

        $db = new MagixSlideshowDb();
        $idSlide = (int)($_POST['id_slide'] ?? 0);
        $isNew = ($idSlide === 0);

        // 1. Sauvegarde du contenu textuel (Multilangue)
        $contentData = [];
        if (isset($_POST['slide_content']) && is_array($_POST['slide_content'])) {
            foreach ($_POST['slide_content'] as $idLang => $c) {
                $contentData[$idLang] = [
                    'title_slide'       => $c['title_slide'] ?? '',
                    // Note pour TinyMCE: On ne met pas de simpleClean ici pour garder le HTML
                    'desc_slide'        => $c['desc_slide'] ?? '',

                    // --- BOUTON 1 ---
                    'link_url_slide'    => FormTool::simpleClean($c['link_url_slide'] ?? ''),
                    'link_label_slide'  => FormTool::simpleClean($c['link_label_slide'] ?? ''),
                    'link_title_slide'  => FormTool::simpleClean($c['link_title_slide'] ?? ''),
                    'blank_slide'       => isset($c['blank_slide']) ? 1 : 0,

                    // --- BOUTON 2 (Nouveau) ---
                    'link2_url_slide'   => FormTool::simpleClean($c['link2_url_slide'] ?? ''),
                    'link2_label_slide' => FormTool::simpleClean($c['link2_label_slide'] ?? ''),
                    'link2_title_slide' => FormTool::simpleClean($c['link2_title_slide'] ?? ''),
                    'blank2_slide'      => isset($c['blank2_slide']) ? 1 : 0,

                    // --- STATUT ---
                    'published_slide'   => isset($c['published_slide']) ? 1 : 0
                ];
            }
        }

        $idSlide = $db->saveSlide($idSlide, [], $contentData);

        if ($idSlide === 0) {
            $this->jsonResponse(false, 'Erreur lors de la sauvegarde du slide.');
        }

        // 2. Gestion de l'Upload d'image
        if (isset($_FILES['img_slide']) && $_FILES['img_slide']['error'] === UPLOAD_ERR_OK) {

            // 🟢 NOUVEAU : Nettoyage du dossier avant le nouvel upload
            // Si c'est une mise à jour (idSlide > 0), on vide le dossier pour supprimer l'ancienne image et ses miniatures
            if (!$isNew) {
                $slideDir = ROOT_DIR . 'upload' . DS . 'magixslideshow' . DS . $idSlide;
                if (is_dir($slideDir)) {
                    FileTool::removeRecursiveFile($slideDir);
                }
            }

            $uploadTool = new UploadTool();

            // GÉNÉRATION DU NOM SEO DYNAMIQUE
            $idLangDefault = (int)($this->defaultLang['id_lang'] ?? 1);

            $slideTitle = $contentData[$idLangDefault]['title_slide'] ?? '';
            $seoName = !empty($slideTitle) ? Url::clean($slideTitle) : 'slide-' . $idSlide;

            $options = [
                'postKey' => 'img_slide',
                'name'    => $seoName // Le fichier s'appellera "mon-super-titre.jpg"
            ];

            // 🟢 MAGIE DU CORE : L'outil crée les dossiers manquants tout seul via UrlTool
            $result = $uploadTool->singleImageUpload(
                'magixslideshow',
                'magixslideshow',
                'upload', // Le root
                ['magixslideshow', (string)$idSlide], // Les sous-dossiers
                $options
            );

            if ($result['status'] === true) {
                $db->updateSlideImage($idSlide, $result['file']);
            } else {
                $this->jsonResponse(false, 'Données sauvées, mais erreur d\'image : ' . $result['msg']);
            }
        } elseif ($isNew) {
            $this->jsonResponse(false, 'L\'image est obligatoire pour créer un nouveau slide.');
        }

        // 3. Retour JSON formaté
        $msg = $isNew ? 'Le slide a été ajouté avec succès.' : 'Le slide a été mis à jour.';

        // Si c'est une édition ET qu'une nouvelle image a été uploadée,
        // il faut dire au navigateur de recharger la page pour voir la nouvelle miniature.
        $reload = (!$isNew && isset($_FILES['img_slide']) && $_FILES['img_slide']['error'] === UPLOAD_ERR_OK);

        if ($reload) {
            // Un petit hack classique pour forcer le JS à recharger la page si MagixForms ne le fait pas par défaut
            $this->jsonResponse(true, $msg, [
                'type' => 'update',
                // MagixForms ne gère pas 'reload' nativement dans handleSuccessResponse pour validate_form,
                // mais si on renvoie un script ou si on s'adapte à ses classes, on peut tricher.
                // Alternativement, on peut renvoyer une URL de redirection vers l'édition elle-même :
                'redirect' => 'index.php?controller=MagixSlideshow&edit=' . $idSlide
            ]);
        } else {
            // Cas normal : l'ajout (redirigé par la classe add_form) ou l'édition simple (texte uniquement)
            $this->jsonResponse(true, $msg, ['type' => $isNew ? 'add' : 'update']);
        }
    }

    /**
     * Suppression native compatible avec table-forms.tpl
     */
    /**
     * Suppression native compatible avec table-forms.tpl
     */
    public function delete(): void
    {
        if (ob_get_length()) ob_clean();

        $token = $_GET['hashtoken'] ?? '';
        if (!$this->session->validateToken(str_replace(' ', '+', $token))) {
            $this->jsonResponse(false, 'Token invalide.');
        }

        // table-forms envoie un tableau "ids[]" ou un "id" simple
        $ids = $_POST['ids'] ?? [$_POST['id'] ?? null];
        $cleanIds = array_filter(array_map('intval', (array)$ids));

        if (!empty($cleanIds)) {
            $db = new MagixSlideshowDb();
            $successCount = 0;

            foreach ($cleanIds as $idSlide) {
                if ($db->deleteSlide($idSlide)) {
                    $successCount++;

                    // 🟢 NOUVEAU : Suppression physique du dossier et de son contenu
                    $slideDir = ROOT_DIR . 'upload' . DS . 'magixslideshow' . DS . $idSlide;
                    FileTool::remove($slideDir);
                }
            }

            if ($successCount > 0) {
                $msg = $successCount > 1 ? 'Les slides ont été supprimés.' : 'Le slide a été supprimé.';
                echo $this->json->encode(['success' => true, 'message' => $msg, 'ids' => $cleanIds]);
                exit;
            }
        }

        echo $this->json->encode(['success' => false, 'message' => 'Aucun slide sélectionné ou erreur de suppression.']);
        exit;
    }
    /**
     * Sauvegarde l'ordre des slides (Drag & Drop depuis table-forms.tpl)
     */
    public function reorder(): void
    {
        if (ob_get_length()) ob_clean();

        // Le token peut être altéré par l'URL, on restaure les espaces (+)
        $rawToken = $_GET['hashtoken'] ?? '';
        $token = str_replace(' ', '+', $rawToken);

        if (!$this->session->validateToken($token)) {
            echo $this->json->encode(['success' => false, 'message' => 'Token invalide']);
            exit;
        }

        // Le JS de table-forms envoie les données en raw payload (php://input)
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);

        if (isset($data['order']) && is_array($data['order'])) {
            $db = new MagixSlideshowDb();
            try {
                $position = 1;
                foreach ($data['order'] as $id) {
                    // On met à jour l'ordre en base de données
                    $db->updateSlideOrder((int)$id, $position);
                    $position++;
                }
                echo $this->json->encode(['success' => true, 'message' => 'Ordre mis à jour avec succès.']);
                exit;
            } catch (\Exception $e) {
                echo $this->json->encode(['success' => false, 'message' => $e->getMessage()]);
                exit;
            }
        }

        echo $this->json->encode(['success' => false, 'message' => 'Données invalides.']);
        exit;
    }
}