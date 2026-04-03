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
                        {* On retire le "position-absolute h-100" ici pour qu'elle donne sa vraie hauteur au slider *}
                        <div class="slide-image-wrapper w-100 z-0">
                            {$is_lazy = ($index > 0)}
                            {include file="components/img.tpl"
                                img=$slide.img
                                size=$device_image_size|default:'large'
                                responsiveC=true
                                lazy=$is_lazy
                                fetchpriority=$prio
                            }

                            {* Voile d'assombrissement (décommentable si besoin) *}
                            {*<div class="position-absolute top-0 start-0 w-100 h-100 bg-dark opacity-50 z-1"></div>*}
                        </div>

                        {* 2. LE TEXTE : EN POSITION ABSOLUE *}
                        {* Ce nouveau div flotte par-dessus l'image et prend 100% de l'espace *}
                        <div class="position-absolute top-0 start-0 w-100 h-100 d-flex align-items-center z-2">

                            {* Votre container d'origine reste intact *}
                            <div class="container py-5">
                                <div class="row w-100 m-0">
                                    <div class="col-12 col-md-10 col-lg-8 col-xl-6 text-white text-center text-lg-start">

                                        {if !empty($slide.title_slide)}
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
                                                   class="btn btn-white-ghost-slide btn-lg px-5 py-3 fw-bold text-uppercase shadow"
                                                   {if !empty($slide.link_title_slide)}title="{$slide.link_title_slide|escape}"{/if}
                                                        {if $slide.blank_slide}target="_blank" rel="noopener noreferrer"{/if}>
                                                    {$slide.link_label_slide|default:{#slideshow_btn_default#}}
                                                </a>
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