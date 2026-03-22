{if isset($slideshow_items) && $slideshow_items|count > 0}
    <div id="magix-hero-slideshow" class="splide magix-slideshow w-100 overflow-hidden" aria-label="Diaporama d'accueil">

        <div class="splide__track">
            <ul class="splide__list">
                {foreach $slideshow_items as $index => $slide}

                    <li class="splide__slide position-relative">

                        {* --- IMAGE EN ARRIÈRE-PLAN --- *}
                        <div class="slide-image-wrapper position-absolute top-0 start-0 w-100 h-100 z-0">
                            {$is_lazy = ($index > 0)}
                            {include file="components/img.tpl"
                            img=$slide.img
                            size=$device_image_size|default:'large'
                            responsiveC=true
                            lazy=$is_lazy
                            class="w-100 h-100 object-fit-cover"}

                            {* Voile d'assombrissement *}
                            {*<div class="position-absolute top-0 start-0 w-100 h-100 bg-dark opacity-50"></div>*}
                        </div>

                        {* --- CONTENU (Texte & Bouton) --- *}
                        <div class="container position-relative h-100 d-flex align-items-center z-1 py-5">
                            <div class="row w-100">
                                <div class="col-12 col-md-10 col-lg-8 col-xl-6 text-white text-center text-lg-start">

                                    {if !empty($slide.title_slide)}
                                        {* Titre responsive : plus petit sur mobile *}
                                        <h2 class="display-5 display-md-3 fw-bold mb-3 text-shadow">
                                            {$slide.title_slide}
                                        </h2>
                                    {/if}

                                    {if !empty($slide.desc_slide)}
                                        <p class="lead mb-4 text-shadow-sm fw-medium">
                                            {$slide.desc_slide|nl2br}
                                        </p>
                                    {/if}

                                    {if !empty($slide.link_url_slide)}
                                        <div class="mt-4">
                                            <a href="{$slide.link_url_slide}"
                                               class="btn btn-primary btn-lg px-5 py-3 fw-bold text-uppercase rounded-pill shadow"
                                               {if !empty($slide.link_title_slide)}title="{$slide.link_title_slide|escape}"{/if}
                                                    {if $slide.blank_slide}target="_blank" rel="noopener noreferrer"{/if}>
                                                {$slide.link_label_slide|default:'Découvrir'}
                                            </a>
                                        </div>
                                    {/if}

                                </div>
                            </div>
                        </div>

                    </li>

                {/foreach}
            </ul>
        </div>
    </div>
{/if}