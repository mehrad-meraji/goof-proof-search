/* SPDX-License-Identifier: AGPL-3.0-or-later */
(function (w, d, searxng) {
  'use strict';

  if (searxng.endpoint !== 'preferences') {
    return;
  }

  searxng.ready(function () {
    let engine_descriptions = null;
    function load_engine_descriptions () {
      if (engine_descriptions == null) {
        searxng.http("GET", "engine_descriptions.json").then(function (content) {
          engine_descriptions = JSON.parse(content);
          for (const [engine_name, description] of Object.entries(engine_descriptions)) {
            let elements = d.querySelectorAll('[data-engine-name="' + engine_name + '"] .engine-description');
            for (const element of elements) {
              let source = ' (<i>' + searxng.settings.translations.Source + ':&nbsp;' + description[1] + '</i>)';
              element.innerHTML = description[0] + source;
            }
          }
        });
      }
    }

    function switchTabs () {
      const aside = document.querySelectorAll('#search_form aside input[type="radio"]');
      const panel = document.querySelectorAll('#search_form .tabs [role="tabpanel"]');
      let selection = null;

      aside.forEach(el => {
        if (el.checked) {
          selection = el.attributes['aria-controls'].nodeValue;
          panel.forEach(el => {
            el.classList.remove('visible');
            if (el.id === selection) {
              el.classList.add('visible');
            }
          });
        }
      });
    }

    const form = document.querySelector('#search_form');

    switchTabs();
    form.addEventListener('change', (e) => {
      if (e.target.name === 'maintab') {
        switchTabs();
      }
    });

    for (const el of d.querySelectorAll('[data-engine-name]')) {
      searxng.on(el, 'mouseenter', load_engine_descriptions);
    }
  });
})(window, document, window.searxng);
