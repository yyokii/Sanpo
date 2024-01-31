memo

+ previewようにviewにDIしたいことがあるが、基本的に protocol 作成して initializer injection するのがいいかも
  + 現状 active record 的な model の運用であるので
  + api client や db を受け渡す必要があるなら environment object 経由でそれらを流すのが良いが、現状必要なさそう
    + https://zenn.dev/matsuji/articles/8ac4c92df4cc73