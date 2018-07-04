# 画像に関するヘルパー。
module ImagesHelper
  # 画像のサイズを変更する。
  # @param [String] image_file 変換元画像ファイルのPATH
  # @param [Integer] new_width 変換後の出力サイズ,長方形(px)
  def img_resize(image_file, new_width)
    document_root = Rails.root.to_s + "/public" + image_file
    img = MiniMagick::Image.open(document_root)
    begin
      propotion = img[:width] / img[:height].to_f
      new_height = new_width / propotion

      if propotion < 1
        new_height = new_width
        new_width *= propotion
      end

      output_filename = document_root
      img.resize("#{new_width}x#{new_height}")
      img.write(output_filename)
    ensure
      img.destroy!
    end
  end

  # 画像のトリミングを行う。
  # @param [String] image_file 変換元画像ファイルのPATH
  # @param [Integer] x 左上(0.0)から指定値へのx座標移動
  # @param [Integer] y 左上(0.0)から指定値へのy座標移動
  # @param [Integer] width 座標移動後に切り取る横幅
  # @param [Integer] height 座標移動後に切り取る縦幅
  # @param [Integer] output_width 出力後の横幅(px)
  def img_cut(image_file, x, y, width, height, output_width)
    document_root = Rails.root.to_s + "/public" + image_file
    img = MiniMagick::Image.open(document_root)
    begin
      zoom_rate = 1
      if output_width.nil?
        zoom_rate = output_width.to_f / (width - x).to_f
        new_width = output_width
        new_height = (height - y) * zoom_rate
      else
        new_width = width - x
        new_height = height - y
      end

      output_filename = document_root
      img.resize("#{output_width * zoom_rate}x#{output_width}")
      img.crop("#{new_width}x#{new_height}+#{x}+#{y}")
      img.write(output_filename)
    ensure
      img.destroy!
    end
  end

  # URI の末尾にモディファイコードを付けた値を返す。
  # 引数 uri にスキーム名を含むフルパスのURIが指定された場合は、そのまま返す。
  # @param uri [String] URI
  # @return ファイルの末尾にモディファイコードを付けた値
  # @example ViewにERBで読み込む。
  #  <%= add_modify_code(uri) %>
  def add_modify_code(uri)
    return unless uri
    return uri if uri =~ %r{^http[s]?:\/\/}

    absolute = uri.start_with?("/")
    if absolute
      path = "/images#{uri}"
    else
      request_path = request.path
      path = "#{request_path}#{"/" unless request_path.end_with?("/")}#{uri}"
    end
    modify_code = compute_modify_code(path)
    params = uri.sub(/.*\?/m, "")
    unless modify_code.nil?
      params = "modify=#{modify_code}#{"&" unless params.nil?}#{params}"
    end

    uri = URI::HTTPS.build({:path => path, :query => params})
    "#{uri.path}#{"?" unless uri.query.nil?}#{uri.query}"
  end

  # 画像イメージ URL を取得する。
  # 引数 URI の先頭が / の場合、 /public/images フォルダーをルートとしたパスを指定する。
  # 引数 URI の先頭が / でない場合は、表示中のページからの相対パスとなる。
  # 返す画像イメージパスにはモディファイコードを付ける。
  # @param uri [String] URI
  # @return 画像イメージパス
  def img_url(uri)
    return unless uri
    return uri if uri =~ %r{^http[s]?:\/\/}

    absolute = uri.start_with?("/")
    if absolute
      path = "/images#{uri}"
    else
      request_path = request.path
      path = "#{request_path}#{"/" unless request_path.end_with?("/")}#{uri}"
    end
    modify_code = compute_modify_code(path)
    params = uri.sub(/.*\?/m, "")
    puts params
    unless modify_code.nil?
      params = "modify=#{modify_code}#{"&" unless params.nil?}#{params}"
    end

    URI::HTTPS.build({:host => Settings.cdn_hostname, :path => path, :query => params}).to_s
  end

  private

  # モディファイコードを返す。
  # @param path [String] /public 移行のパス
  # @return モディファイコード
  def compute_modify_code(path)
    return unless path

    path = "#{"/" unless path.start_with?("/")}#{path}"

    fullpath = Rails.root.join("public#{path}")
    return unless File.exist?(fullpath)

    File.mtime(fullpath).to_i
  end
end
