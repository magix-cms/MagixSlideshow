{extends file="layout.tpl"}

{block name='head:title'}Édition du Slide{/block}

{block name="article"}
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="bi bi-pencil-square me-2"></i> {if $slide.id_slide == 0}Ajouter un Slide{else}Modifier le Slide #{$slide.id_slide}{/if}
        </h1>
        <a href="index.php?controller=MagixSlideshow" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Retour à la liste
        </a>
    </div>

    {* 🟢 CORRECTION 1 : Ajout dynamique de la classe "add_form" pour que MagixForms déclenche la redirection *}
    <form action="index.php?controller=MagixSlideshow&action=saveSlide" method="post" enctype="multipart/form-data" class="validate_form {if $slide.id_slide == 0}add_form{/if}">
        <input type="hidden" name="hashtoken" value="{$hashtoken|default:''}">
        <input type="hidden" name="id_slide" value="{$slide.id_slide|default:0}">

        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3 d-flex align-items-center justify-content-between">
                <h6 class="m-0 fw-bold text-primary">Image du slide</h6>
                {if isset($langs)}{include file="components/dropdown-lang.tpl"}{/if}
            </div>

            <div class="card-body p-4">
                <div class="mb-4 bg-light p-3 rounded border">
                    <label class="form-label fw-bold">Fichier Image {if $slide.id_slide == 0}<span class="text-danger">*</span>{/if}</label>

                    {* 🟢 CORRECTION 2 : On utilise le chemin absolu direct et on ajoute un ID "preview-image" *}
                    {if !empty($slide.img_slide)}
                        <div class="d-flex align-items-center bg-white p-3 border rounded shadow-sm mb-3">
                            <div class="me-3">
                                <img id="preview-image" src="/upload/magixslideshow/{$slide.id_slide}/{$slide.img_slide}" alt="Aperçu" class="img-thumbnail" style="max-height: 90px; object-fit: cover;">
                            </div>
                            <div>
                                <span class="d-block fw-bold text-success"><i class="bi bi-check-circle-fill me-1"></i> Image actuellement en ligne</span>
                                <small class="text-muted d-block mb-1">Fichier : <strong>{$slide.img_slide}</strong></small>
                                <small class="text-muted"><em>Chargez un nouveau fichier ci-dessous pour la remplacer.</em></small>
                            </div>
                        </div>
                    {/if}

                    {* Ajout d'un ID "img_input" pour le script JS *}
                    <input type="file" id="img_input" name="img_slide" class="form-control" accept="image/*" {if $slide.id_slide == 0}required{/if}>
                </div>

                <div class="tab-content" id="myTabContent">
                    {if isset($langs)}
                        {foreach $langs as $idLang => $iso}
                            <div class="tab-pane fade {if $iso@first}show active{/if}" id="lang-{$idLang}" role="tabpanel">

                                <div class="row g-3">
                                    <div class="col-md-9">
                                        <label class="form-label fw-medium">Titre (H2)</label>
                                        <input type="text" name="slide_content[{$idLang}][title_slide]" class="form-control" value="{$slide.content[$idLang].title_slide|default:''}">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-medium d-block">Statut</label>
                                        <div class="form-check form-switch mt-2">
                                            <input class="form-check-input" type="checkbox" role="switch" name="slide_content[{$idLang}][published_slide]" value="1" {if ($slide.content[$idLang].published_slide|default:1) == 1}checked{/if}>
                                            <label class="form-check-label text-muted">Publié</label>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label fw-medium">Description courte</label>
                                        <textarea name="slide_content[{$idLang}][desc_slide]" class="form-control" rows="3">{$slide.content[$idLang].desc_slide|default:''}</textarea>
                                    </div>

                                    <div class="col-12">
                                        <div class="p-3 bg-light rounded border border-light-subtle">
                                            <h6 class="fw-bold mb-3 small text-uppercase text-muted"><i class="bi bi-link-45deg"></i> Bouton d'action (Optionnel)</h6>
                                            <div class="row g-3">
                                                <div class="col-md-6">
                                                    <label class="form-label small">Texte du bouton</label>
                                                    <input type="text" name="slide_content[{$idLang}][link_label_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link_label_slide|default:''}">
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label small">URL de destination</label>
                                                    <input type="text" name="slide_content[{$idLang}][link_url_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link_url_slide|default:''}">
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label small">Attribut Title du lien</label>
                                                    <input type="text" name="slide_content[{$idLang}][link_title_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link_title_slide|default:''}">
                                                </div>
                                                <div class="col-md-6 d-flex align-items-end">
                                                    <div class="form-check mb-1">
                                                        <input class="form-check-input" type="checkbox" name="slide_content[{$idLang}][blank_slide]" value="1" {if ($slide.content[$idLang].blank_slide|default:0) == 1}checked{/if}>
                                                        <label class="form-check-label small">Ouvrir dans un nouvel onglet (_blank)</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        {/foreach}
                    {/if}
                </div>
            </div>

            <div class="card-footer bg-light text-end py-3">
                <button type="submit" class="btn btn-primary px-4">
                    <i class="bi bi-save me-2"></i> Enregistrer
                </button>
            </div>
        </div>
    </form>
{/block}

{* 🟢 CORRECTION 3 : Suppression de MagixFormTools et ajout d'un script de preview instantanée *}
{block name="javascripts" append}
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Prévisualisation instantanée de l'image (Plus besoin de recharger la page !)
            const imgInput = document.getElementById('img_input');
            const previewImg = document.getElementById('preview-image');

            if (imgInput && previewImg) {
                imgInput.addEventListener('change', function() {
                    if (this.files && this.files[0]) {
                        // Crée une URL temporaire pour afficher l'image sélectionnée instantanément
                        previewImg.src = URL.createObjectURL(this.files[0]);
                    }
                });
            }
        });
    </script>
{/block}