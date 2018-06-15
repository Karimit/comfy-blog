# frozen_string_literal: true

class Comfy::Blog::Post < ActiveRecord::Base

  self.table_name = "comfy_blog_posts"

  include Comfy::Cms::WithFragments
  include Comfy::Cms::WithCategories

  cms_has_revisions_for :fragments_attributes

  # -- Relationships -----------------------------------------------------------
  belongs_to :site,
    class_name: "Comfy::Cms::Site"

  # -- Validations -------------------------------------------------------------
  validates :title, :slug, :year, :month,
    presence: true
  validates :slug,
    uniqueness: { scope: %i[site_id year month] },
    format:     { with: /[a-zA-Z0-9\-_\p{Arabic}]+\z/i }

  # -- Scopes ------------------------------------------------------------------
  scope :published, -> { where(is_published: true) }
  scope :for_year,  ->(year) { where(year: year) }
  scope :for_month, ->(month) { where(month: month) }

  # -- Callbacks ---------------------------------------------------------------
  before_validation :set_slug,
                    :set_published_at,
                    :set_date

  # -- Instance Mathods --------------------------------------------------------
  def url(relative: false)
    public_blog_path = ComfyBlog.config.public_blog_path
    post_path = ["/", public_blog_path, year, month, slug].join("/").squeeze("/")
    [site.url(relative: relative), post_path].join
  end

protected

  def set_slug
    t = title.to_s
    self.slug = normalize_friendly_id(t) if slug.blank?
  end

  def normalize_friendly_id(value)
    sep = '-'
    parameterized_string = value.gsub(/[^a-zA-Z0-9\-_\p{Arabic}]+/, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep) # No more than one of the separator in a row.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '') # Remove leading/trailing separator.
    end
    parameterized_string
  end

  def set_date
    self.year   = published_at.year
    self.month  = published_at.month
  end

  def set_published_at
    self.published_at ||= Time.zone.now
  end

end
