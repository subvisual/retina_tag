
module RetinaTag
  module TagHelper
    def self.included(base)
      base.alias_method_chain :image_tag, :retina
    end

    def image_tag_with_retina(source,options={})
      hidpi_asset_path = nil
      src = options[:src] = path_to_image(source)

      begin
          retina_els = source.split('.')
          extension = retina_els.last
          retina_els.slice!(-1)
          retina_path = "#{retina_els.join('.')}@2x.#{extension}"

          if !Rails.application.assets.find_asset(retina_path).nil?
            puts "Found HIDPI Asset"
            hidpi_asset_path = asset_path(retina_path)
          end
      rescue
      end
      options_default = { :hidpi_src => hidpi_asset_path }

      if lazy = options.delete(:lazy)
        options["data-lazy-load"] = lazy
      end

      options_default.merge!(options)
      puts "Checking for #{source} #{options_default}"
      image_tag_without_retina(source,options_default)

      if options_default[:"data-lazy-load"]
        options_default[:lowdpi_src] = options_default.delete(:src)
      end

      tag("img", options_default)
    end


  end

  class Engine < ::Rails::Engine
    initializer :retina_tag_image_tag do
      ActionView::Helpers::AssetTagHelper.module_eval do
        include TagHelper
      end

    end
  end
end
