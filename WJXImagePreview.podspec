Pod::Spec.new do |s|
s.name = 'WJXImagePreview'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = '图片预览'
s.description = '图片预览,支持本地图片预览/网络图片'
s.homepage = 'https://github.com/wangjixiao1992/WJXImagePreview'
s.authors = {'wangjixiao' => '642907599@qq.com' }
s.source = {:git => "https://github.com/wangjixiao1992/WJXImagePreview.git", :tag => "v1.0.0"}
s.source_files  = "**/*.{h,m}"
s.platform = :ios, "8.0"
s.requires_arc = false
s.library = “SDWebImage”
end
