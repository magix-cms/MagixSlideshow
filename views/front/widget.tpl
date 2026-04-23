{if isset($slideshow_items) && $slideshow_items|count > 0}
    <div id="magix-hero-slideshow" class="splide magix-slideshow w-100 overflow-hidden" aria-label="{#slideshow_aria_label#}">
        <div class="splide__track">
            <ul class="splide__list">
                {foreach $slideshow_items as $index => $slide}
                    {if $slide@first}
                        {$is_lazy = false}
                        {$prio = 'high'}
                    {else}
                        {$is_lazy = true}
                        {$prio = ''}
                    {/if}

                    <li class="splide__slide position-relative">

                        {* 1. L'IMAGE : DANS LE FLUX NORMAL *}
                        <div class="slide-image-wrapper w-100 z-0">
                            {$is_lazy = ($index > 0)}
                            {include file="components/img.tpl"
                            img=$slide.img
                            size="large"
                            responsiveC=true
                            lazy=$is_lazy
                            fetchpriority=$prio
                            }
                        </div>

                        {* 2. LE TEXTE : EN POSITION ABSOLUE *}
                        <div class="position-absolute top-0 start-0 w-100 h-100 d-flex align-items-center z-2">

                            <div class="container py-5">
                                <div class="row w-100 m-0">
                                    <div class="col-12 col-md-10 col-lg-8 col-xl-4 text-white text-center text-lg-start">

                                        {if !empty($slide.title_slide)}
                                            <p class="display-5 display-md-3 fw-bold mb-3 text-shadow d-none d-md-block">
                                                {$slide.title_slide}
                                            </p>
                                        {/if}

                                        {* 🟢 CORRECTION 1 : div au lieu de p + nofilter pour interpréter TinyMCE *}
                                        {if !empty($slide.desc_slide)}
                                            <div class="lead mb-4 text-shadow fw-medium d-none d-md-block tinymce-content">
                                                {$slide.desc_slide nofilter}
                                            </div>
                                        {/if}

                                        {* 🟢 CORRECTION 2 : Conteneur Flex pour aligner les deux boutons *}
                                        {if !empty($slide.link_url_slide) || !empty($slide.link2_url_slide)}
                                            <div class="mt-4 d-flex gap-3 justify-content-center justify-content-lg-start flex-wrap">

                                                {* BOUTON 1 PRINCIPAL *}
                                                {if !empty($slide.link_url_slide)}
                                                    <a href="{$slide.link_url_slide}"
                                                       class="btn btn-white-ghost-slide btn-lg px-4 py-3 fw-bold text-uppercase shadow"
                                                       {if !empty($slide.link_title_slide)}title="{$slide.link_title_slide|escape}"{/if}
                                                            {if $slide.blank_slide}target="_blank" rel="noopener noreferrer"{/if}>
                                                        {$slide.link_label_slide|default:{#slideshow_btn_default#}}
                                                    </a>
                                                {/if}

                                                {* BOUTON 2 SECONDAIRE *}
                                                {if !empty($slide.link2_url_slide)}
                                                    <a href="{$slide.link2_url_slide}"
                                                            {* Vous pouvez changer 'btn-primary' par 'btn-outline-light' selon le rendu désiré *}
                                                       class="btn btn-main btn-lg px-4 py-3 fw-bold text-uppercase shadow"
                                                            {if !empty($slide.link2_title_slide)}title="{$slide.link2_title_slide|escape}"{/if}
                                                            {if $slide.blank2_slide}target="_blank" rel="noopener noreferrer"{/if}>
                                                        {$slide.link2_label_slide|default:'En savoir plus'}
                                                    </a>
                                                {/if}

                                            </div>
                                        {/if}

                                    </div>
                                </div>
                            </div>

                        </div>
                    </li>
                {/foreach}
            </ul>
        </div>
    </div>
{/if}