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

                    <input type="file" id="img_input" name="img_slide" class="form-control" accept="image/*" {if $slide.id_slide == 0}required{/if}>
                </div>

                <div class="tab-content" id="myTabContent">
                    {if isset($langs)}
                        {foreach $langs as $idLang => $iso}
                            <div class="tab-pane fade {if $iso@first}show active{/if}" id="lang-{$idLang}" role="tabpanel">

                                <div class="row g-4">
                                    {* Ligne 1 : Titre et Statut *}
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

                                    {* 🟢 MODIFICATION : Ajout de la classe mceEditor pour TinyMCE *}
                                    <div class="col-12">
                                        <label class="form-label fw-medium">Description du slide</label>
                                        <textarea name="slide_content[{$idLang}][desc_slide]" class="form-control mceEditor" rows="8">{$slide.content[$idLang].desc_slide|default:''}</textarea>
                                    </div>

                                    {* 🟢 MODIFICATION : Disposition côte à côte des deux boutons d'action *}
                                    <div class="col-12">
                                        <div class="row g-3">

                                            {* BOUTON 1 *}
                                            <div class="col-lg-6">
                                                <div class="p-3 bg-light rounded border border-light-subtle h-100">
                                                    <h6 class="fw-bold mb-3 small text-uppercase text-primary"><i class="bi bi-1-circle"></i> Bouton d'action principal</h6>
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
                                                            <label class="form-label small">Attribut Title</label>
                                                            <input type="text" name="slide_content[{$idLang}][link_title_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link_title_slide|default:''}">
                                                        </div>
                                                        <div class="col-md-6 d-flex align-items-end">
                                                            <div class="form-check mb-1">
                                                                <input class="form-check-input" type="checkbox" name="slide_content[{$idLang}][blank_slide]" value="1" {if ($slide.content[$idLang].blank_slide|default:0) == 1}checked{/if}>
                                                                <label class="form-check-label small">Nouvel onglet (_blank)</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            {* BOUTON 2 (NOUVEAU) *}
                                            <div class="col-lg-6">
                                                <div class="p-3 bg-light rounded border border-light-subtle h-100">
                                                    <h6 class="fw-bold mb-3 small text-uppercase text-secondary"><i class="bi bi-2-circle"></i> Bouton secondaire (Optionnel)</h6>
                                                    <div class="row g-3">
                                                        <div class="col-md-6">
                                                            <label class="form-label small">Texte du bouton</label>
                                                            <input type="text" name="slide_content[{$idLang}][link2_label_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link2_label_slide|default:''}">
                                                        </div>
                                                        <div class="col-md-6">
                                                            <label class="form-label small">URL de destination</label>
                                                            <input type="text" name="slide_content[{$idLang}][link2_url_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link2_url_slide|default:''}">
                                                        </div>
                                                        <div class="col-md-6">
                                                            <label class="form-label small">Attribut Title</label>
                                                            <input type="text" name="slide_content[{$idLang}][link2_title_slide]" class="form-control form-control-sm" value="{$slide.content[$idLang].link2_title_slide|default:''}">
                                                        </div>
                                                        <div class="col-md-6 d-flex align-items-end">
                                                            <div class="form-check mb-1">
                                                                <input class="form-check-input" type="checkbox" name="slide_content[{$idLang}][blank2_slide]" value="1" {if ($slide.content[$idLang].blank2_slide|default:0) == 1}checked{/if}>
                                                                <label class="form-check-label small">Nouvel onglet (_blank)</label>
                                                            </div>
                                                        </div>
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

{block name="javascripts" append}
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Prévisualisation instantanée de l'image
            const imgInput = document.getElementById('img_input');
            const previewImg = document.getElementById('preview-image');

            if (imgInput && previewImg) {
                imgInput.addEventListener('change', function() {
                    if (this.files && this.files[0]) {
                        previewImg.src = URL.createObjectURL(this.files[0]);
                    }
                });
            }
        });
    </script>
{/block}