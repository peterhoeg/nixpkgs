{
  activesupport = {
    dependencies = ["i18n" "minitest" "thread_safe" "tzinfo"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s12j8vl8vrxfngkdlz9g8bpz9akq1z42d57mx5r537b2pji8nr7";
      type = "gem";
    };
    version = "4.2.10";
  };
  addressable = {
    dependencies = ["public_suffix"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0viqszpkggqi8hq87pqp0xykhvz60g99nwmkwsb0v45kc2liwxvk";
      type = "gem";
    };
    version = "2.5.2";
  };
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
      sha256 = "0m137lnjf63ym9zqcrnmxwnl891bdarqxii8b1z2dsy5rsviq5gi";
      type = "gem";
    };
    version = "2.10.61";
  };
  aws-sdk-core = {
    dependencies = ["aws-sigv4" "jmespath"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n4mf0q8ias7387simj2psww70sckl5v0jwcm7zpjb5pwfqdwrrs";
      type = "gem";
    };
    version = "2.10.61";
  };
  aws-sdk-resources = {
    dependencies = ["aws-sdk-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yq8icqpxjfc8js8c22vcim1ixzj112ma5x8wkvsgwifrjckq9wk";
      type = "gem";
    };
    version = "2.10.61";
  };
  aws-ses = {
    dependencies = ["builder" "mail" "mime-types" "xml-simple"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dssck23xhm1x4lz9llflvxc5hi17zpgshb32p9xpja7kwv035pf";
      type = "gem";
    };
    version = "0.6.0";
  };
  aws-sigv4 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g0qzy2xkmy6cr1qcz0k53fqgja1732h93vnna4fq5mz55lzlvkl";
      type = "gem";
    };
    version = "1.0.2";
  };
  builder = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qibi5s67lpdv1wgcj66wcymcr04q6j4mzws6a479n0mlrmh5wr1";
      type = "gem";
    };
    version = "3.2.3";
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
  chronic_duration = {
    dependencies = ["numerizer"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k7sx3xqbrn6s4pishh2pgr4kw6fmw63h00lh503l66k8x0qvigs";
      type = "gem";
    };
    version = "0.10.6";
  };
  cookiejar = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q0kmbks9l3hl0wdq744hzy97ssq9dvlzywyqv9k9y1p3qc9va2a";
      type = "gem";
    };
    version = "0.3.3";
  };
  dentaku = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11z4cw4lspx3rgmmd2hd4l1iikk6p17icxwn7xym92v1j825zpnr";
      type = "gem";
    };
    version = "2.0.9";
  };
  dnsbl-client = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1357r0y8xfnay05l9h26rrcqrjlnz0hy421g18pfrwm1psf3pp04";
      type = "gem";
    };
    version = "1.0.2";
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
  em-http-request = {
    dependencies = ["addressable" "cookiejar" "em-socksify" "eventmachine" "http_parser.rb"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13rxmbi0fv91n4sg300v3i9iiwd0jxv0i6xd0sp81dx3jlx7kasx";
      type = "gem";
    };
    version = "1.1.5";
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
  em-socksify = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wbbg48vnv4kgpdpxfmh3bjn2wv0g7gbpw5f7vccfbrrzvyq9fgg";
      type = "gem";
    };
    version = "0.3.1";
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
  erubis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  eventmachine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "075hdw0fgzldgss3xaqm2dk545736khcvv1fmzbf1sgdlkyh1v8z";
      type = "gem";
    };
    version = "1.2.5";
  };
  ffi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "034f52xf7zcqgbvwbl20jwdyjwznvqnwpbaps9nk18v9lgb1dpx0";
      type = "gem";
    };
    version = "1.9.18";
  };
  history = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n46rl8cf155c7h411w3gz94c28psvjv4zvrf1nla9symd05hivi";
      type = "gem";
    };
    version = "0.3.0";
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
  "http_parser.rb" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  i18n = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i3aqvzfsj786kwjj70jsjpxm6ffw5pwhalzr2abjfv2bdc7k9kw";
      type = "gem";
    };
    version = "0.8.6";
  };
  influxdb = {
    dependencies = ["cause" "json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jikl3iylbffsdmb4vr09ysqvpwxk133y6m9ylwcd0931ngsf0ks";
      type = "gem";
    };
    version = "0.3.13";
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
      sha256 = "1gwhrd7xlysq537yy8ma69jc83lblwiccajl5zvyqpnwyjjc93df";
      type = "gem";
    };
    version = "0.5.8";
  };
  language = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "100jdf11ldzymczxxyfgqzbybi0qzghvzxxlqwaw02izz5svjn46";
      type = "gem";
    };
    version = "0.6.0";
  };
  mail = {
    dependencies = ["mime-types"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nbg60h3cpnys45h7zydxwrl200p7ksvmrbxnwwbpaaf9vnf3znp";
      type = "gem";
    };
    version = "2.6.3";
  };
  mailgun-ruby = {
    dependencies = ["json" "rest-client"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aqa0ispfn27g20s8s517cykghycxps0bydqargx7687w6d320yb";
      type = "gem";
    };
    version = "1.0.3";
  };
  mime-types = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03j98xr0qw2p2jkclpmk7pm29yvmmh0073d8d43ajmr0h3w7i5l9";
      type = "gem";
    };
    version = "2.99.3";
  };
  minitest = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05521clw19lrksqgvg2kmm025pvdhdaniix52vmbychrn2jm7kz2";
      type = "gem";
    };
    version = "5.10.3";
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
      sha256 = "1raim9ddjh672m32psaa9niw67ywzjbxbdb8iijx3wv9k5b0pk2x";
      type = "gem";
    };
    version = "1.12.2";
  };
  net-ping = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19p3d39109xvbr4dcjs3g3zliazhc1k3iiw69mgb1w204hc7wkih";
      type = "gem";
    };
    version = "1.7.8";
  };
  netrc = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  numerizer = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vrk9jbv4p4dcz0wzr72wrf5kajblhc5l9qf7adbcwi4qvz9xv0h";
      type = "gem";
    };
    version = "0.1.1";
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
  public_suffix = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0snaj1gxfib4ja1mvy3dzmi7am73i0mkqr0zkz045qv6509dhj5f";
      type = "gem";
    };
    version = "3.0.0";
  };
  redis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i415x8gi0c5vsiy6ikvx5js6fhc4x80a5lqv8iidy2iymd20irv";
      type = "gem";
    };
    version = "3.3.5";
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
  ruby-ntlm = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xg4wjxhv19n04q8knb2ac9mmdiqp88rc1dkzdxcmy0wrn2w2j0n";
      type = "gem";
    };
    version = "0.0.3";
  };
  ruby_dig = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qcpmf5dsmzxda21wi4hv7rcjjq4x1vsmjj20zpbj5qg2k26hmp9";
      type = "gem";
    };
    version = "0.0.2";
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
      sha256 = "0jn1wimx502y5acglvda50ha4h66bhngb174y8hq2cprgl435f15";
      type = "gem";
    };
    version = "1.1.0";
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
  sensu-extensions-influxdb = {
    dependencies = ["em-http-request" "multi_json" "sensu-extension"];
    source = {
      fetchSubmodules = false;
      rev = "c6ccfbd12fd878d4a30096444d8a022aac433252";
      sha256 = "00cr0bsklx0m7ygrzj0j1gf1axa8dpv8fy8bvdvkrl0z253lyx6b";
      type = "git";
      url = "git://github.com/sensu-extensions/sensu-extensions-influxdb2.git";
    };
    version = "0.0.2";
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
  sensu-extensions-snmp-trap = {
    dependencies = ["sensu-extension" "snmp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01ipy73yf2lwnhka15y3n9nbmhr9rbkprqcsfiz1n0mcb2hm4vxd";
      type = "gem";
    };
    version = "0.0.33";
  };
  sensu-extensions-system-profile = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kzx06svvqxf39v1wx51mxcp2xz8pmhq3irxva15294708rc76wj";
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
      sha256 = "0z18zk04l9klbjmqvjg6cpv3k4w5hi1by8wnpkiwdwa2jdv61jyb";
      type = "gem";
    };
    version = "1.4.5";
  };
  sensu-plugins-cgroups = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ql491ddyfp1n9dm0w1k395wyzqmvm6rh2w6qv7d01gsmpr7p55d";
      type = "gem";
    };
    version = "1.1.0";
  };
  sensu-plugins-disk-checks = {
    dependencies = ["sensu-plugin" "sys-filesystem"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zcqk7d92dvbyigk8g1phsacvgv87jrxcghg28wsxzi2whqs1xi5";
      type = "gem";
    };
    version = "2.5.0";
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
      sha256 = "18nk7c451df46xcjk97r3h8yhaj8bz138ih5y0z26sdiha58brv7";
      type = "gem";
    };
    version = "1.2.0";
  };
  sensu-plugins-ipmi = {
    dependencies = ["rubyipmi" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10jg1cyjxbnzmwyrq0bkdy6nzjs9fql0jxl0829lhgxmxk0hhn86";
      type = "gem";
    };
    version = "1.0.1";
  };
  sensu-plugins-load-checks = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q8lzv5vyahciywai6irsz2z3n3s66w5lcrhyljqwcan4v16ps4v";
      type = "gem";
    };
    version = "4.0.0";
  };
  sensu-plugins-logs = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sd9gqdvw1iy8vykilxfa0vwx45avk8inlqwsqhi8g3sm9j3yp4g";
      type = "gem";
    };
    version = "1.3.1";
  };
  sensu-plugins-mailer = {
    dependencies = ["aws-ses" "erubis" "mail" "mailgun-ruby" "ruby-ntlm" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05hyf07cafsgkh9hpm9kn96fl6kal63022qzm7scmdnjvknfdkf4";
      type = "gem";
    };
    version = "1.2.0";
  };
  sensu-plugins-network-checks = {
    dependencies = ["activesupport" "dnsbl-client" "net-ping" "sensu-plugin" "whois" "whois-parser"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yjwlqa08hbfhwqn1wnhsss5bzpjzxrd7clxgxrhm2c1qirc8cwh";
      type = "gem";
    };
    version = "2.0.1";
  };
  sensu-plugins-pushover = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bn9j2r1d4id2fizykfhrbwxx60jpf3hc965ziwz0rwbqvp02xnb";
      type = "gem";
    };
    version = "1.0.0";
  };
  sensu-plugins-rabbitmq = {
    dependencies = ["amq-protocol" "bunny" "carrot-top" "inifile" "rest-client" "ruby_dig" "sensu-plugin" "stomp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hx6ws9k06pcrck584rhxg47qsgbg9x36mpzb8sy7w3wb8c8hjr3";
      type = "gem";
    };
    version = "3.6.0";
  };
  sensu-plugins-raid-checks = {
    dependencies = ["english" "sensu-plugin"];
    source = {
      fetchSubmodules = false;
      rev = "5b13a690f317c96c8b44f90af767de2842adfae4";
      sha256 = "10rrymxy8cvw4jnbsvprlldgi41z854pg34m7ijbhcf4j45dg1jn";
      type = "git";
      url = "git://github.com/sensu-plugins/sensu-plugins-raid-checks.git";
    };
    version = "1.0.0";
  };
  sensu-plugins-redis = {
    dependencies = ["redis" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cfay3c70l7k3qylrk0f1yp4fn6c8ds410b11mlkwhwmk9jl92xn";
      type = "gem";
    };
    version = "2.2.1";
  };
  sensu-plugins-sensu = {
    dependencies = ["chronic_duration" "english" "rest-client" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hmxvka29c1kw1qh0pwxhj7kdvs816680dja27ya1dczs48ifpw4";
      type = "gem";
    };
    version = "2.3.1";
  };
  sensu-plugins-snmp = {
    dependencies = ["sensu-plugin" "snmp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0089d4dxbg3k58m8xr59vwnp8bq2468qmcfd9ss71jhfwjxs1kla";
      type = "gem";
    };
    version = "1.1.0";
  };
  sensu-plugins-systemd = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f0hdp2cvzs5wby2fkjg48siyjgdi83hf11ld1by2l0cn4s9ir24";
      type = "gem";
    };
    version = "0.1.0";
  };
  sensu-plugins-uptime-checks = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11ab9gg3kdf9pihna35lf799qrzpv208z9q6n34bvf17izjxhpwh";
      type = "gem";
    };
    version = "1.2.0";
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
      sha256 = "1ml8gcm1rcs3z0xspp5yv1995yydk749saawaza8iam3mgc6fk3z";
      type = "gem";
    };
    version = "10.9.0";
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
  thread_safe = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tzinfo = {
    dependencies = ["thread_safe"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05r81lk7q7275rdq7xipfm0yxgqyd2ggh73xpc98ypngcclqcscl";
      type = "gem";
    };
    version = "1.2.3";
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
  whois = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "181kvz2imh05paq7qzkjw08m5r05ymbbrkv9z5n3z8amik629b1i";
      type = "gem";
    };
    version = "4.0.4";
  };
  whois-parser = {
    dependencies = ["activesupport" "whois"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i0lqkfhyk0qm97ic8kaxwg36nnvfvqx1jhl0wxvhvc4bylz2708";
      type = "gem";
    };
    version = "1.0.0";
  };
  xml-simple = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xlqplda3fix5pcykzsyzwgnbamb3qrqkgbrhhfz2a2fxhrkvhw8";
      type = "gem";
    };
    version = "1.1.5";
  };
}