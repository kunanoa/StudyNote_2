class Image < ApplicationRecord
  attr_accessor :id, :repository, :tag, :created, :image_size, :port_host, :port_container, :container_name

  # バリデーション処理
  validates :id, length: { maximum: 12 }, format: {with: /\A([a-z0-9]+)\z/}, allow_blank: true
  validates :repository, length: { maximum: 15 }, format: {with: /\A([A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9]|\<none\>)\z/}
  validates :tag, length: { maximum: 12 }, format: {with: /\A([A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9]|\<none\>)\z/}
  validates :image_size, length: { maximum: 10 }, format: {with: /\A([A-Za-z0-9.]+)\z/}, allow_blank: true
  validates :created, length: { maximum: 22 }, format: {with: /\A([A-Za-z0-9 ]+)\z/}, allow_blank: true
  validates :port_host, length: { in: 1..65535 }, allow_blank: true
  validates :port_container, length: { in: 1..65535 }, allow_blank: true
  validates :container_name, length: { maximum: 30 }, format: {with: /\A([a-zA-Z0-9_.-]+)\z/}, allow_blank: true


  def self.all
    count = `docker images -q`.chomp.split("\n").count
    images = []
    repository_tag = `docker images --format "{{.ID}} {{.Repository}} {{.Tag}} {{.Size}} {{.CreatedSince}}"`.chomp.split("\n")
    repository_tag.each do |repository_tag|
      repository_tag = repository_tag.split(" ")
      id, repository, tag, image_size = repository_tag[0], repository_tag[1], repository_tag[2], repository_tag[3]
      created = repository_tag[4..(repository_tag.size)].join(' ')
      image = Image.new()
      image.image_info(id, repository, tag, image_size, created)
      images << image
    end
    images
  end

  def image_info(id, repository, tag, image_size, created)
    @id = id
    @repository = repository
    @tag = tag
    @created = created
    @image_size = image_size
    @port_host = ""
    @port_container = ""
    @container_name = ""
  end

  def create_container(repository, tag, port_host, port_container, container_name)
    flag = true
    if container_name != ""
      container_name = "--name #{container_name}" 
    end
    
    if port_host != "" && port_container != ""
      ports = "-p #{port_host}:#{port_container}"
    elsif port_host == "" && port_container == ""
      ports = ""
    else
      flag = false
    end

    if flag != false
      `docker run -d #{container_name} -it #{ports} #{repository}:#{tag}`
    end
    flag
  end

  def change_repository_tag_name(id, repository, tag)
    flag = true
    if repository == "" || tag == ""
      flag = false
    elsif repository == "<none>" || tag == "<none>"
      flag = false
    else
      `docker tag #{id} #{repository}:#{tag}`
    end
    flag
  end

  # 対象イメージを削除する。
  def delete_image(id, repository, tag, image_size, created)
    `docker rmi #{repository}:#{tag}`
    # 削除に成功したかどうかを確認する。（結果はboolean型で返す）
    `sleep 1`
    `(docker images --format "{{.Repository}} {{.Tag}}" | grep "^#{repository} #{tag}$")`.split("\n").size == 0
  end

  def delete_unused_image()
    `docker image prune -f`
    # 削除に成功したかどうかを確認する。（結果はboolean型で返す）
    `sleep 1`
    `(docker images --format "{{.Repository}} {{.Tag}}" | grep "<none>")`.split("\n").size == 0
  end
end
