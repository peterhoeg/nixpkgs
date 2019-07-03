{
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  mixlib-cli = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0647msh7kp7lzyf6m72g6snpirvhimjm22qb8xgv9pdhbcrmcccp";
      type = "gem";
    };
    version = "1.7.0";
  };
  rubyipmi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1saipskzdnxk8rb6qscnmkw7q6jjw4krifbszxkilarr5ln7m4cq";
      type = "gem";
    };
    version = "0.10.0";
  };
  sensu-plugin = {
    dependencies = ["json" "mixlib-cli"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x4zka4zia2wk3gp0sr4m4lzsf0m7s4a3gcgs936n2mgzsbcaa86";
      type = "gem";
    };
    version = "1.4.7";
  };
  sensu-plugins-ipmi = {
    dependencies = ["rubyipmi" "sensu-plugin"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "19c3fdf5fdc8740d29ddf5d6af9f36d6448121a8";
      sha256 = "1zlh0as7bwgjv9qns9fiz7xwj5wfgrkhhkpi7krwwxh25b8nvhm8";
      type = "git";
      url = "git@github.com:speartail/sensu-plugins-ipmi.git";
    };
    version = "1.0.1";
  };
}