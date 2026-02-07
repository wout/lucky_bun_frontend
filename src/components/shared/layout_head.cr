class Shared::LayoutHead < BaseComponent
  needs page_title : String

  def render
    head do
      utf8_charset
      title "My App - #{@page_title}"
      css_link asset("css/app.css")
      js_link asset("js/app.js"), defer: "true"
      csrf_meta_tags
      responsive_meta_tag

      live_reload_connect_tag if LuckyEnv.development?
      bun_reload_connect_tag
    end
  end

  private def bun_reload_connect_tag
    return unless LuckyEnv.development?

    config = Lucky::Bun::Config.load
    css_files = Lucky::AssetHelpers.css_entry_points
      .map { |key| File.join(config.public_path, key) }

    script do
      raw <<-JS
      (() => {
        const cssPaths = #{css_files.to_json};
        const ws = new WebSocket('#{config.dev_server.ws_url}')

        ws.onmessage = (event) => {
          const data = JSON.parse(event.data)

          if (data.type === 'css') {
            document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
              const linkPath = new URL(link.href).pathname.split('?')[0]
              if (cssPaths.some(p => linkPath.startsWith(p))) {
                const url = new URL(link.href)
                url.searchParams.set('r', Date.now())
                link.href = url.toString()
              }
            })
            console.log('▸ CSS reloaded')
          } else if (data.type === 'error') {
            console.error('✖ Build error:', data.message)
          } else {
            console.log('▸ Reloading...')
            location.reload()
          }
        }

        ws.onopen = () => console.log('▸ Live reload connected')
        ws.onclose = () => setTimeout(() => location.reload(), 2000)
      })()
      JS
    end
  end
end
