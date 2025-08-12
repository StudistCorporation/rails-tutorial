require 'open-uri'

# タグの作成
tags = %w[研修 新人教育 オンボーディング 人事 総務 開発 営業 マーケティング].map do |name|
  Tag.find_or_create_by!(name: name)
end

# マニュアル1: 新人研修の進め方
manual1 = Manual.create!(
  title: '新人研修の進め方',
  description: '新入社員の研修プログラムの全体的な流れと重要なポイントについて解説します。'
)

# サムネイル画像を設定
begin
  manual1.thumbnail.attach(
    io: URI.open('https://picsum.photos/seed/training/400/300'),
    filename: 'training_thumbnail.jpg',
    content_type: 'image/jpeg'
  )
rescue => e
  puts "Warning: Could not attach thumbnail for manual1: #{e.message}"
end

manual1.tags << tags[0..2]  # 研修, 新人教育, オンボーディング

steps1 = manual1.steps.create!([
  {
    title: '研修の事前準備',
    description: '研修を成功させるためには、事前準備が非常に重要です。必要な資料の準備、会場の手配、参加者への連絡など、チェックリストを活用して漏れのないように準備しましょう。',
    position: 1
  },
  {
    title: '初日のオリエンテーション',
    description: '新入社員が会社に馴染めるよう、初日は特に重要です。会社の理念・ビジョンの説明、組織構成の紹介、基本的なルールの説明などを行います。',
    position: 2
  },
  {
    title: '業務研修の実施',
    description: '実際の業務に必要な知識やスキルを身につけてもらいます。座学だけでなく、実践的な演習も取り入れることで、より効果的な研修になります。',
    position: 3
  },
  {
    title: 'フォローアップ',
    description: '研修後も定期的にフォローアップを行い、新入社員の成長をサポートします。1on1ミーティングやメンター制度を活用しましょう。',
    position: 4
  }
])

# ステップに画像を追加
steps1.each_with_index do |step, index|
  begin
    step.image.attach(
      io: URI.open("https://picsum.photos/seed/training-step-#{index + 1}/600/400"),
      filename: "training_step_#{index + 1}.jpg",
      content_type: 'image/jpeg'
    )
  rescue => e
    puts "Warning: Could not attach image for step: #{e.message}"
  end
end

# マニュアル2: リモートワークのベストプラクティス
manual2 = Manual.create!(
  title: 'リモートワークのベストプラクティス',
  description: '効率的で生産的なリモートワークを実現するためのガイドラインです。'
)

# サムネイル画像を設定
begin
  manual2.thumbnail.attach(
    io: URI.open('https://picsum.photos/seed/remote-work/400/300'),
    filename: 'remote_work_thumbnail.jpg',
    content_type: 'image/jpeg'
  )
rescue => e
  puts "Warning: Could not attach thumbnail for manual2: #{e.message}"
end

manual2.tags << [tags[3], tags[5]]  # 人事, 開発

steps2 = manual2.steps.create!([
  {
    title: '作業環境の整備',
    description: '快適な作業環境を整えることが、生産性向上の第一歩です。適切なデスクと椅子、十分な照明、安定したインターネット接続を確保しましょう。',
    position: 1
  },
  {
    title: 'コミュニケーションツールの活用',
    description: 'Slack、Zoom、Microsoft Teamsなどのツールを効果的に使い分けます。用途に応じて最適なツールを選択し、チームメンバーとの円滑なコミュニケーションを心がけましょう。',
    position: 2
  },
  {
    title: 'タイムマネジメント',
    description: '自宅での作業は集中力の維持が課題です。ポモドーロテクニックなどを活用し、適度な休憩を取りながら効率的に作業を進めましょう。',
    position: 3
  }
])

# ステップに画像を追加
steps2.each_with_index do |step, index|
  begin
    step.image.attach(
      io: URI.open("https://picsum.photos/seed/remote-step-#{index + 1}/600/400"),
      filename: "remote_step_#{index + 1}.jpg",
      content_type: 'image/jpeg'
    )
  rescue => e
    puts "Warning: Could not attach image for step: #{e.message}"
  end
end

# 追加のマニュアルを作成
manual3 = Manual.create!(
  title: '経費精算の手順',
  description: '経費申請から承認までのフローをわかりやすく解説します。'
)

begin
  manual3.thumbnail.attach(
    io: URI.open('https://picsum.photos/seed/expense/400/300'),
    filename: 'expense_thumbnail.jpg',
    content_type: 'image/jpeg'
  )
rescue => e
  puts "Warning: Could not attach thumbnail for manual3: #{e.message}"
end

manual3.tags << tags[4]  # 総務

manual3.steps.create!([
  {
    title: '経費申請書の作成',
    description: '必要な領収書を準備し、経費申請システムに入力します。',
    position: 1
  },
  {
    title: '上長の承認',
    description: '申請内容を上長が確認し、承認または差し戻しを行います。',
    position: 2
  },
  {
    title: '経理部門の処理',
    description: '承認された申請を経理部門が確認し、支払い処理を行います。',
    position: 3
  }
])

manual4 = Manual.create!(
  title: 'Gitの基本操作',
  description: '開発チームで必須のGitの基本的な使い方を解説します。'
)

begin
  manual4.thumbnail.attach(
    io: URI.open('https://picsum.photos/seed/git/400/300'),
    filename: 'git_thumbnail.jpg',
    content_type: 'image/jpeg'
  )
rescue => e
  puts "Warning: Could not attach thumbnail for manual4: #{e.message}"
end

manual4.tags << tags[5]  # 開発

manual4.steps.create!([
  {
    title: 'リポジトリのクローン',
    description: 'git cloneコマンドを使ってリモートリポジトリをローカルにコピーします。',
    position: 1
  },
  {
    title: 'ブランチの作成と切り替え',
    description: '新機能やバグ修正のために新しいブランチを作成し、作業を開始します。',
    position: 2
  },
  {
    title: 'コミットとプッシュ',
    description: '変更をコミットし、リモートリポジトリにプッシュします。',
    position: 3
  }
])

puts "Seeded #{Manual.count} manuals, #{Tag.count} tags, and #{Step.count} steps."
puts "Thumbnails attached: #{Manual.joins(:thumbnail_attachment).count}"
puts "Step images attached: #{Step.joins(:image_attachment).count}"
