class Container < ApplicationRecord
    
  attr_accessor :id, :name, :new_name, :status, :port, :repository, :tag

  # バリデーション処理
  validates :id, length: { is: 12 }, format: {with: /\A([a-z0-9]+)\z/}
  validates :status, format: { with: /\A(稼働中|停止)\z/ }, allow_blank: true
  validates :name, length: { maximum: 30 }, format: {with: /\A([a-zA-Z0-9_.-]+)\z/}, allow_blank: true
  validates :new_name, length: { maximum: 30 }, format: {with: /\A([a-zA-Z0-9_.-]+)\z/}, allow_blank: true
  validates :repository, length: { maximum: 15 }, format: {with: /\A([A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9])\z/}, allow_blank: true
  validates :tag, length: { maximum: 12 }, format: {with: /\A([A-Za-z0-9]+[A-Za-z0-9_-]+[A-Za-z0-9])\z/}, allow_blank: true
  
  def self.all
    ids = `docker ps -a --format "{{.ID}}"`.chomp.split("\n")

    containers = []
    ids.each do |id|
      container = Container.new()
      container.container_info(id)
      containers << container
    end
    containers
  end

  def container_info(id)
    @id = id
    @name = `docker ps -af "id=#{id}" --format '{{.Names}}'`.chomp
    @status = `docker ps -af "id=#{id}" --format '{{.Status}}'`.chomp
    @port = `docker ps -af "id=#{id}" --format '{{.Ports}}'`.chomp
    image_name = `docker ps -af "id=#{id}" --format '{{.Image}}'`.chomp
    if image_name.include?(":")
      @repository = image_name.split(":")[0]
      @tag = image_name.split(":")[1]
    else
      @repository = image_name
      @tag = "latest"
    end
  
    if @status.include?("Up")
      @status = "稼働中"
    else
      @status = "停止"
    end
  end

  def create_image(id, repository, tag)
    flag = true
    if repository == ""
      flag = false
    elsif tag == ""
      tag = "latest"
      `docker commit #{id} #{repository}:#{tag}`
    else
      `docker commit #{id} #{repository}:#{tag}`
    end
    flag
  end

  # 対象コンテナのステータス情報から、コンテナが起動中か停止中かを判別し、起動/停止させる。
  def start_stop_container(id, status)
    before_status = status
    if status.include?("稼働中")
      `docker container stop #{id}`
    else
      `docker container start #{id}`
    end

    # 1秒待って、ステータスが変化しているか確認する。（結果はboolean型で返す）
    `sleep 1`
    container_info(id)
    @status != before_status
  end

  def change_name(id, name, new_name)
    flag = true
    if name == "" || new_name == ""
      flag = false
    else
      `docker rename #{name} #{new_name}`
    end
    flag
  end

  # 対象コンテナIDと一致するコンテナを削除する。
  def delete_container(id)
    container_info(id)
    `docker rm -f #{id}`

    # 削除に成功したかどうかを確認する。（結果はboolean型で返す）
    `sleep 1`
    `docker ps -aqf "id=#{id}"`.chomp.size == 0
  end
end
