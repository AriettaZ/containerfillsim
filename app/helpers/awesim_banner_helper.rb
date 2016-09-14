# Namespace for methods that help with formatting the AweSim banner text.
module AwesimBannerHelper

  # Create a formatted html <h1> header tag based on an input phrase.
  #
  # @param [String] greytext The phrase to be parsed.
  # @param [String, nil] redtext To explicitly specify the text to make red. Otherwise, use the last word of the phrase if the greytext has more than one word.
  #
  # awesim_banner("Container Fill Sim") => "Container Fill" is grey, "Sim" is red
  # awesim_banner("Container Fill", "Sim") => "Container Fill" is grey, "Sim" is red
  # awesim_banner("Oakley", "Desktop Manager") => "Oakley" is grey, "Desktop Manager" is red
  # awesim_banner("Oakley Desktop", "") => "Oakley Desktop" is grey
  #
  # @return [String] A formatted <h1> block of html with the parsed text.
  #   => <h1 class="awesim-banner-title">Hello World <span>Sim</span></h1>
  def awesim_banner(greytext, redtext=nil)

    if redtext.nil?
      words = greytext.split

      if words.length > 1
        redtext = words.last
        greytext = words[0..-2].join(" ")
      end
    end

    "<h1 class=\"awesim-banner-title\">#{greytext} <span>#{redtext}</span></h1>".html_safe
  end

  # Returns a titleized string of the application Class name.
  #
  # @see http://apidock.com/rails/ActiveSupport/Inflector/titleize
  #
  # @return [String] The parent name of the application class that has been titleized.
  def app_title
    AwesimRails.app_title || Rails.application.class.parent_name.titleize
  end

  # creates the parent link with appropriate styles
  def bootstrap_nav_awesim_dashboard_link
    bootstrap_nav_breadcrumbs_dashboard_link('Apps', OodAppkit.dashboard.url.to_s)
  end


  # creates a divider
  def bootstrap_nav_awesim_breadcrumb_divider
    "<span class='navbar-brand navbar-spacer'>/</span>".html_safe
  end

  # Create a formatted html block including a link back to the app dashboard for navigation
  #
  # @param [String, nil] apptitle The title of the app. If nil, use the titleized app_title.
  # @param [String, nil] applink The link to the app. If nil, use the root_path.
  #
  # @return [String] A block of html that contains a link to the dashboard and the root path of the app.
  def awesim_breadcrumbs(apptitle=app_title,applink=root_path)
    bootstrap_nav_awesim_dashboard_link +
        bootstrap_nav_awesim_breadcrumb_divider +
        bootstrap_nav_breadcrumbs_link(apptitle, applink)
  end

  #FIXME: title and url here should be constants defined somewhere else...
  def bootstrap_nav_breadcrumbs_dashboard_link(title=OodAppkit.dashboard.title, url=OodAppkit.dashboard.url.to_s)
    link_to(title, url, class: 'navbar-brand navbar-home')
  end

  def bootstrap_nav_breadcrumbs_link(title, url="#")
    link_to(title, url, class: 'navbar-brand')
  end

  def ood_breadcrumbs(apptitle=app_title,applink=root_path)
    bootstrap_nav_breadcrumbs_dashboard_link +
        bootstrap_nav_awesim_breadcrumb_divider +
        bootstrap_nav_breadcrumbs_link(apptitle, applink)
  end
end
