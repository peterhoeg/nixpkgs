{
  amq-protocol = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rpn9vgh7y037aqhhp04smihzr73vp5i5g6xlqlha10wy3q0wp7x";
      type = "gem";
    };
    version = "2.0.1";
  };
  amqp = {
    dependencies = ["amq-protocol" "eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kbrqnpjgj9v0722p3n5rw589l4g26ry8mcghwc5yr20ggkpdaz9";
      type = "gem";
    };
    version = "1.6.0";
  };
  aws-sdk = {
    dependencies = ["aws-sdk-resources"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cpsh1zfckf90q9j8hsyjqcs0nc63h37my0vvnpqqs8gc4dm3850";
      type = "gem";
    };
    version = "2.10.20";
  };
  aws-sdk-core = {
    dependencies = ["aws-sigv4" "jmespath"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03438y5996pqjfh9cn2iqjnbsyacmrbw3d3hkf8m3zjh56lp5kql";
      type = "gem";
    };
    version = "2.10.20";
  };
  aws-sdk-resources = {
    dependencies = ["aws-sdk-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n91n5ccmih9npg1bz0yzvqp0h0sg9vxrs01nkg8djx7n9rgdfgz";
      type = "gem";
    };
    version = "2.10.20";
  };
  aws-sigv4 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cxl0yvmyl8d0yj4cx3p75iki4fqk8ckb6ajfj7mr3g4ihp5mryp";
      type = "gem";
    };
    version = "1.0.1";
  };
  bunny = {
    dependencies = ["amq-protocol"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aa8hsg5vnsrq5ra5k7jhfdq5zibaxy5fd6zzmsyzsg4agv4dqds";
      type = "gem";
    };
    version = "2.5.0";
  };
  carrot-top = {
    dependencies = ["json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bj8290f3h671qf7sdc2vga0iis86mvcsvamdi9nynmh9gmfis5w";
      type = "gem";
    };
    version = "0.0.7";
  };
  cause = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0digirxqlwdg79mkbn70yc7i9i1qnclm2wjbrc47kqv6236bpj00";
      type = "gem";
    };
    version = "0.1";
  };
  childprocess = {
    dependencies = ["ffi"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lv7axi1fhascm9njxh3lx1rbrnsm8wgvib0g7j26v4h1fcphqg0";
      type = "gem";
    };
    version = "0.5.8";
  };
  dentaku = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kzhcpasly6kxrraf1p6yxwpk13cllvcrbgl6vza0f23x1hylw8h";
      type = "gem";
    };
    version = "1.2.6";
  };
  domain_name = {
    dependencies = ["unf"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12hs8yijhak7p2hf1xkh98g0mnp5phq3mrrhywzaxpwz1gw5r3kf";
      type = "gem";
    };
    version = "0.5.20170404";
  };
  em-http-server = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y8l4gymy9dzjjchjav90ck6has2i2zdjihlhcyrg3jgq6kjzyq5";
      type = "gem";
    };
    version = "0.1.8";
  };
  em-worker = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z4jx9z2q5hxvdvik4yp0ahwfk69qsmdnyp72ln22p3qlkq2z5wk";
      type = "gem";
    };
    version = "0.0.2";
  };
  english = {
    dependencies = ["language"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dijqzkm3ika6jw3ma3w1b097gnzll13h5cjhxpdywahz34f44f9";
      type = "gem";
    };
    version = "0.6.3";
  };
  eventmachine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00mlcq33q104spkb5c997lwallpilhj0d6fzsbd4lr9s8lmjga5f";
      type = "gem";
    };
    version = "1.2.2";
  };
  ffi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "034f52xf7zcqgbvwbl20jwdyjwznvqnwpbaps9nk18v9lgb1dpx0";
      type = "gem";
    };
    version = "1.9.18";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
    version = "1.0.3";
  };
  influxdb = {
    dependencies = ["cause" "json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pdq8wj9p0s7iyqnb6z4qjixifr6sr5iszssnfzgrljd3x4bg8j4";
      type = "gem";
    };
    version = "0.2.2";
  };
  inifile = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c5zmk7ia63yw5l2k14qhfdydxwi1sah1ppjdiicr4zcalvfn0xi";
      type = "gem";
    };
    version = "3.0.0";
  };
  jmespath = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07w8ipjg59qavijq59hl82zs74jf3jsp7vxl9q3a2d0wpv5akz3y";
      type = "gem";
    };
    version = "1.3.1";
  };
  json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  jsonpath = {
    dependencies = ["multi_json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b9cr6i9frqgm96fp60h87jdplasi14ckqgl1gfgs74jbspbbs1f";
      type = "gem";
    };
    version = "0.5.7";
  };
  language = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "100jdf11ldzymczxxyfgqzbybi0qzghvzxxlqwaw02izz5svjn46";
      type = "gem";
    };
    version = "0.6.0";
  };
  mime-types = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03j98xr0qw2p2jkclpmk7pm29yvmmh0073d8d43ajmr0h3w7i5l9";
      type = "gem";
    };
    version = "2.99.3";
  };
  mixlib-cli = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0647msh7kp7lzyf6m72g6snpirvhimjm22qb8xgv9pdhbcrmcccp";
      type = "gem";
    };
    version = "1.7.0";
  };
  multi_json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wpc23ls6v2xbk3l1qncsbz16npvmw8p0b38l8czdzri18mp51xk";
      type = "gem";
    };
    version = "1.12.1";
  };
  netrc = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  oj = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "147whmq8h2n04chskl3v4a132xhz5i6kk6vhnz83jwng4vihin5f";
      type = "gem";
    };
    version = "2.18.1";
  };
  parse-cron = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02fj9i21brm88nb91ikxwxbwv9y7mb7jsz6yydh82rifwq7357hg";
      type = "gem";
    };
    version = "0.1.4";
  };
  redis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kdj7511l6kqvqmaiw7kw604c83pk6f4b540gdsq1bf7yxm6qx6g";
      type = "gem";
    };
    version = "3.3.3";
  };
  rest-client = {
    dependencies = ["http-cookie" "mime-types" "netrc"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1m8z0c4yf6w47iqz6j2p7x1ip4qnnzvhdph9d5fgx081cvjly3p7";
      type = "gem";
    };
    version = "1.8.0";
  };
  rubyipmi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1saipskzdnxk8rb6qscnmkw7q6jjw4krifbszxkilarr5ln7m4cq";
      type = "gem";
    };
    version = "0.10.0";
  };
  sensu = {
    dependencies = ["em-http-server" "eventmachine" "parse-cron" "sensu-extension" "sensu-extensions" "sensu-json" "sensu-logger" "sensu-redis" "sensu-settings" "sensu-spawn" "sensu-transport"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vk9bvxwh6ah8xkncf16f8r0bq84cnnx16ffc4k6sq73v8wpk116";
      type = "gem";
    };
    version = "1.0.2";
  };
  sensu-extension = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lgmjxfbq11v4yi3qanf1qxv0sgm1a8a7wj7qyn1nkva6zmimss3";
      type = "gem";
    };
    version = "1.5.1";
  };
  sensu-extensions = {
    dependencies = ["sensu-extension" "sensu-extensions-check-dependencies" "sensu-extensions-debug" "sensu-extensions-json" "sensu-extensions-occurrences" "sensu-extensions-only-check-output" "sensu-extensions-ruby-hash" "sensu-json" "sensu-logger" "sensu-settings"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r09mdbbnh5cg9yvqw78sxbhlb8xqld1vwbr4hsjw6k3x1xpnnr9";
      type = "gem";
    };
    version = "1.9.0";
  };
  sensu-extensions-check-dependencies = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0clgvf2abvwz549f28ny3zd6q7z6y7m49i8pp91ll10jp1vsy4b2";
      type = "gem";
    };
    version = "1.0.1";
  };
  sensu-extensions-debug = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11abdgn2kkkbvxq4692yg6a27qnxz4349gfiq7d35biy7vrw34lp";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-extensions-json = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wnbn9sycdqdh9m0fhszaqkv0jijs3fkdbvcv8kdspx6irbv3m6g";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-extensions-occurrences = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lx5wsbblfs0rvkxfg09bsz0g2mwmckrhga7idnarsnm8m565v1v";
      type = "gem";
    };
    version = "1.2.0";
  };
  sensu-extensions-only-check-output = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ds2i8wd4ji9ifig2zzr4jpxinvk5dm7j10pvaqy4snykxa3rqh3";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-extensions-ruby-hash = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xyrj3gbmslbivcd5qcmyclgapn7qf7f5jwfvfpw53bxzib0h7s3";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-json = {
    dependencies = ["oj"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02qkh86jddv7gha39vjx6g9hi7vkq7r433dr86bwmm9c7lqkgyl9";
      type = "gem";
    };
    version = "2.1.0";
  };
  sensu-logger = {
    dependencies = ["eventmachine" "sensu-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03kicjqz8a594bxnwyg6bcd4fipy2vxjl1gbaip4gpixxki32dx0";
      type = "gem";
    };
    version = "1.2.1";
  };
  sensu-plugin = {
    dependencies = ["json" "mixlib-cli"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k8mkkwb70z2j5lq457y7lsh5hr8gzd53sjbavpqpfgy6g4bxrg8";
      type = "gem";
    };
    version = "1.2.0";
  };
  sensu-plugins-disk-checks = {
    dependencies = ["sensu-plugin" "sys-filesystem"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r7kzqp0kwhz7kk0s25r7lh2sw4yr99m5lr8cb99kq73fnsjqipq";
      type = "gem";
    };
    version = "2.4.0";
  };
  sensu-plugins-http = {
    dependencies = ["aws-sdk" "rest-client" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13126hx2fgjsrfqnlh2hf2czn35pi8rkc5ql9yxf4y8x9a7dyksj";
      type = "gem";
    };
    version = "2.5.0";
  };
  sensu-plugins-influxdb = {
    dependencies = ["dentaku" "influxdb" "jsonpath" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n06lhiiqmbc4j0j5zalkk5835frbpqayzf1viqmcnmwmbmq9463";
      type = "gem";
    };
    version = "0.0.7";
  };
  sensu-plugins-ipmi = {
    dependencies = ["rubyipmi" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19afqwhq9w7yi9c2in6q1mzv5fqryf5278pdlkhgq4mgv0hp1b0h";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-plugins-logs = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ycrf3967v5kavm58fj9db16l9wgyzac4h3r0f9hm32jy9qsxwq6";
      type = "gem";
    };
    version = "1.2.0";
  };
  sensu-plugins-rabbitmq = {
    dependencies = ["amq-protocol" "bunny" "carrot-top" "inifile" "rest-client" "sensu-plugin" "stomp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cc3j98lkqsfrnvzq9151hlgm5hzciqg040awkwm59sx0l0hywpy";
      type = "gem";
    };
    version = "3.2.0";
  };
  sensu-plugins-redis = {
    dependencies = ["redis" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j4hgp5546qbmwqzcd9ipvbpzgsch33xbgr4aw6yj7h8f0shxnyc";
      type = "gem";
    };
    version = "2.0.0";
  };
  sensu-plugins-sensu = {
    dependencies = ["english" "rest-client" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sycmdn2sv137n9hgj8a742x6dcb45i775rgc85i6mkv14y9q97y";
      type = "gem";
    };
    version = "1.1.0";
  };
  sensu-plugins-snmp = {
    dependencies = ["sensu-plugin" "snmp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bfmhs3lsv26pi8x0xbj93x5x6n0m21if74njkqs9adj69253hby";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-plugins-systemd = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r7prvkf33j6qvvqq78186rn5g6wf0g3dqni34vnj8v1z287wkfh";
      type = "gem";
    };
    version = "0.0.5";
  };
  sensu-redis = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1drmychc04fg2gs7zsxx6aidfyxf7cn7k8k1jy7dnfbnlr5aln3n";
      type = "gem";
    };
    version = "2.2.0";
  };
  sensu-settings = {
    dependencies = ["parse-cron" "sensu-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y55bqvps06gk94zllamqr0fa5bc27q0k1b5sp5gxh1bkf4w8gb3";
      type = "gem";
    };
    version = "10.3.0";
  };
  sensu-spawn = {
    dependencies = ["childprocess" "em-worker" "eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz5kbqk3ld0s16zjl8m38l1m1xwcvjlfc1g4nfm45qxdyfn7la7";
      type = "gem";
    };
    version = "2.2.1";
  };
  sensu-transport = {
    dependencies = ["amq-protocol" "amqp" "eventmachine" "sensu-redis"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15yib92hwyd8v04wcc0kaw0p8w2c2mwvi4ldya2jh3dqgs31mvhr";
      type = "gem";
    };
    version = "7.0.2";
  };
  snmp = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "164dgdakbgvfr1v4nax7jqdrv8vfziwj73q970i6yjmcjxjbg870";
      type = "gem";
    };
    version = "1.2.0";
  };
  stomp = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11nac3vqrfq162154rl9411i93cp53xa09ih8l4bya0xb0kpyakc";
      type = "gem";
    };
    version = "1.4.3";
  };
  sys-filesystem = {
    dependencies = ["ffi"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10didky52nfapmybj6ipda18i8fcwf8bs9bbfbk5i7v1shzd36rf";
      type = "gem";
    };
    version = "1.1.7";
  };
  unf = {
    dependencies = ["unf_ext"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14hr2dzqh33kqc0xchs8l05pf3kjcayvad4z1ip5rdjxrkfk8glb";
      type = "gem";
    };
    version = "0.0.7.4";
  };
}