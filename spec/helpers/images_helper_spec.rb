require "rails_helper"
require "fileutils"

describe ImagesHelper do

  describe "#add_modify_code" do
    let :helper do
      double("helper", :request => double("request", :path => "/images/foo")).extend(ImagesHelper)
    end
    let :helper_root do
      double("helper_root", :request => double("request", :path => "/images")).extend(ImagesHelper)
    end
    around :each do |example|
      FileUtils.touch("#{Rails.root.to_s}/public/images/foo")
      example.run
      FileUtils.rm("#{Rails.root.to_s}/public/images/foo")
    end
    context "引数に存在しないファイルの相対パスを指定する場合" do
      it "モディファイコードをつけないで返す。" do
        expect(helper.add_modify_code("bar")).to eq "/images/foo/bar"
      end
    end
    context "引数に存在するファイルの相対パスを指定する場合" do
      it "モディファイコードをつけて返す。" do
        expect(helper_root.add_modify_code("foo")).to match %r{\/images\/foo\?modify=[0-9]+$}
      end
    end
    context "引数に存在しないファイルの絶対パスを指定する場合" do
      it "モディファイコードをつけないで返す。" do
        expect(helper.add_modify_code("/bar")).to eq "/images/bar"
      end
    end
    context "引数に存在するファイルの絶対パスを指定する場合" do
      it "モディファイコードをつけて返す。" do
        expect(helper.add_modify_code("/foo")).to match %r{\/images\/foo\?modify=[0-9]+$}
      end
    end
    context "引数にnilを指定する場合" do
      it "nil を返す。" do
        expect(helper.add_modify_code(nil)).to be_nil
      end
    end
    context "引数にFQDNを指定する場合" do
      it "引数に指定された FQDN そのものを返す。" do
        expect(helper.add_modify_code("http://localhost.local/path/to/file")).to eq "http://localhost.local/path/to/file"
        expect(helper.add_modify_code("https://localhost.local/path/to/file")).to eq "https://localhost.local/path/to/file"
      end
    end
  end

  #----------------------------------------

  describe "#img_url" do

    describe "https://localhost/images/foo からのアクセスであり" do
      let :helper do
        double("helper", :request => double("request", :path => "/images/foo")).extend(ImagesHelper)
      end
      context "引数に相対パスを指定する場合" do
        it "https://localhost/images/foo/bar を返す。" do
          expect(helper.img_url("bar")).to eq "https://localhost/images/foo/bar"
        end
      end
      context "引数に絶対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("/bar")).to eq "https://localhost/images/bar"
        end
      end
      context "引数にクエリー文字列ありの相対パスを指定する場合" do
        it "https://localhost/images/foo/bar?a=1&b=1 を返す。" do
          expect(helper.img_url("bar?a=1&b=1")).to eq "https://localhost/images/foo/bar?a=1&b=1"
        end
      end
      context "引数にクエリー文字列ありの絶対パスを指定する場合" do
        it "https://localhost/images/bar?a=1&b=1 を返す。" do
          expect(helper.img_url("/bar?a=1&b=1")).to eq "https://localhost/images/bar?a=1&b=1"
        end
      end
      context "引数にnilを指定する場合" do
        it "nil を返す。" do
          expect(helper.img_url(nil)).to be_nil
        end
      end
      context "引数にFQDNを指定する場合" do
        it "引数に指定された FQDN そのものを返す。" do
          expect(helper.img_url("http://localhost.local/path/to/file")).to eq "http://localhost.local/path/to/file"
          expect(helper.img_url("https://localhost.local/path/to/file")).to eq "https://localhost.local/path/to/file"
        end
      end
    end

    describe "https://localhost/images からのアクセスであり" do
      let :helper do
        double("helper", :request => double("request", :path => "/images")).extend(ImagesHelper)
      end
      context "引数に相対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("bar")).to eq "https://localhost/images/bar"
        end
      end
      context "引数に絶対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("/bar")).to eq "https://localhost/images/bar"
        end
      end
      context "引数にクエリー文字列ありの相対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("bar?a=1&b=1")).to eq "https://localhost/images/bar?a=1&b=1"
        end
      end
      context "引数にクエリー文字列ありの絶対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("/bar?a=1&b=1")).to eq "https://localhost/images/bar?a=1&b=1"
        end
      end
      context "引数にnilを指定する場合" do
        it "nil を返す。" do
          expect(helper.img_url(nil)).to be_nil
        end
      end
      context "引数にFQDNを指定する場合" do
        it "引数に指定された FQDN そのものを返す。" do
          expect(helper.img_url("http://localhost.local/path/to/file")).to eq "http://localhost.local/path/to/file"
          expect(helper.img_url("https://localhost.local/path/to/file")).to eq "https://localhost.local/path/to/file"
        end
      end
    end

    describe "https://localhost/ からのアクセスであり" do
      let :helper do
        double("helper", :request => double("request", :path => "/")).extend(ImagesHelper)
      end
      context "引数に相対パスを指定する場合" do
        it "https://localhost/bar を返す。" do
          expect(helper.img_url("bar")).to eq "https://localhost/bar"
        end
      end
      context "引数に絶対パスを指定する場合" do
        it "https://localhost/images/bar を返す。" do
          expect(helper.img_url("/bar")).to eq "https://localhost/images/bar"
        end
      end
      context "引数にクエリー文字列ありの相対パスを指定する場合" do
        it "https://localhost/bar?a=1&b=1 を返す。" do
          expect(helper.img_url("bar?a=1&b=1")).to eq "https://localhost/bar?a=1&b=1"
        end
      end
      context "引数にクエリー文字列ありの絶対パスを指定する場合" do
        it "https://localhost/images/bar?a=1&b=1 を返す。" do
          expect(helper.img_url("/bar?a=1&b=1")).to eq "https://localhost/images/bar?a=1&b=1"
        end
      end
      context "引数にnilを指定する場合" do
        it "nil を返す。" do
          expect(helper.img_url(nil)).to be_nil
        end
      end
      context "引数にFQDNを指定する場合" do
        it "引数に指定された FQDN そのものを返す。" do
          expect(helper.img_url("http://localhost.local/path/to/file")).to eq "http://localhost.local/path/to/file"
          expect(helper.img_url("https://localhost.local/path/to/file")).to eq "https://localhost.local/path/to/file"
        end
      end
    end
  end
end
