{
  activesupport = {
    dependencies = ["i18n" "minitest" "thread_safe" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pqr25wmhvvlg8av7bi5p5c7r5464clhhhhv45j63bh7xw4ad6n4";
      type = "gem";
    };
    version = "4.2.11";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bcm2hchn897xjhqj9zzsxf3n9xhddymj4lsclz508f4vw3av46l";
      type = "gem";
    };
    version = "2.6.0";
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
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vdvk05ijzg4d4rfgvv2jzq8dfhjyf534bdfm8wm6k7wnh6smsj8";
      type = "gem";
    };
    version = "2.11.212";
  };
  aws-sdk-core = {
    dependencies = ["aws-sigv4" "jmespath"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vxqpb10w3k2ihsprpmz5r4i0i6w1va0y2nprjp8f1crc3sbd16y";
      type = "gem";
    };
    version = "2.11.212";
  };
  aws-sdk-resources = {
    dependencies = ["aws-sdk-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1m88892k184gg7d2wd26wyja19z0w7zd4vz3giczfk9zyira64d4";
      type = "gem";
    };
    version = "2.11.212";
  };
  aws-sdk-v1 = {
    dependencies = ["json" "nokogiri"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1riv52n8rga04xp3d3fr07fwnzhc4h6ivw23544fck80z481mm92";
      type = "gem";
    };
    version = "1.66.0";
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
      sha256 = "1hzndv113i6bgy2n72i5l3mwn8vjnb6hhjxfkpn9mm2p5ra77yk7";
      type = "gem";
    };
    version = "1.0.3";
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
  CFPropertyList = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hadm41xr1fq3qp74jd9l5q8l0j9083rgklgzsilllwaav7qrrid";
      type = "gem";
    };
    version = "2.3.6";
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
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ixcx9pfissxrga53jbdpza85qd5f6b5nq1sfqa9rnfq82qnlbp1";
      type = "gem";
    };
    version = "1.1.4";
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
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1357r0y8xfnay05l9h26rrcqrjlnz0hy421g18pfrwm1psf3pp04";
      type = "gem";
    };
    version = "1.0.2";
  };
  dnsruby = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04sxvjif1pxmlf02mj3hkdb209pq18fv9sr2p0mxwi0dpifk6f3x";
      type = "gem";
    };
    version = "1.61.2";
  };
  domain_name = {
    dependencies = ["unf"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0abdlwb64ns7ssmiqhdwgl27ly40x2l27l8hs8hn0z4kb3zd2x3v";
      type = "gem";
    };
    version = "0.5.20180417";
  };
  dry-inflector = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jnik7afnfx0rczvxd7pxf2z1swjm83rbbm246jdmdflqkwgq7qj";
      type = "gem";
    };
    version = "0.1.2";
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
      sha256 = "0rk43ywaanfrd8180d98287xv2pxyl7llj291cwy87g1s735d5nk";
      type = "gem";
    };
    version = "0.3.2";
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
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  excon = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15l9w0938c19nxmrp09n75qpmm64k12xj69h47yvxzcxcpbgnkb2";
      type = "gem";
    };
    version = "0.62.0";
  };
  ffi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0c2dl10pi6a30kcvx2s6p2v1wb4kbm48iv38kmz2ff600nirhpb8";
      type = "gem";
    };
    version = "1.9.21";
  };
  fission = {
    dependencies = ["CFPropertyList"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09pmp1j1rr8r3pcmbn2na2ls7s1j9ijbxj99xi3a8r6v5xhjdjzh";
      type = "gem";
    };
    version = "0.5.0";
  };
  fog = {
    dependencies = ["fog-atmos" "fog-aws" "fog-brightbox" "fog-core" "fog-ecloud" "fog-google" "fog-json" "fog-local" "fog-powerdns" "fog-profitbricks" "fog-radosgw" "fog-riakcs" "fog-sakuracloud" "fog-serverlove" "fog-softlayer" "fog-storm_on_demand" "fog-terremark" "fog-vmfusion" "fog-voxel" "fog-xml" "ipaddress" "nokogiri"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "188b0ijg667v4r9k67kmm2hknic9q1dvhcc363dnijm6m6fz8c06";
      type = "gem";
    };
    version = "1.32.0";
  };
  fog-atmos = {
    dependencies = ["fog-core" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aaxgnw9zy96gsh4h73kszypc32sx497s6bslvhfqh32q9d1y8c9";
      type = "gem";
    };
    version = "0.1.0";
  };
  fog-aws = {
    dependencies = ["fog-core" "fog-json" "fog-xml" "ipaddress"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00skbbgvhqzq6gpgzmw0957n0wf1y3vjgrdyq3sib0ghpyfgmig3";
      type = "gem";
    };
    version = "2.0.1";
  };
  fog-brightbox = {
    dependencies = ["dry-inflector" "fog-core" "fog-json" "mime-types"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z0azs8119v4v3xrds822pyv7137cy8kgsmbjmf96l717qzr4b4p";
      type = "gem";
    };
    version = "0.16.1";
  };
  fog-core = {
    dependencies = ["builder" "excon" "formatador"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ac25s2wv7m6av7h7vjzd2bg3srhnn5yrz3lq1xpimhnfmp82sw6";
      type = "gem";
    };
    version = "1.43.0";
  };
  fog-ecloud = {
    dependencies = ["fog-core" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y2vvhsa1kz8mchzby5rfznsmlwzfqcl8gbgkb0mqjkby9sw3jdx";
      type = "gem";
    };
    version = "0.1.1";
  };
  fog-google = {
    dependencies = ["fog-core" "fog-json" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lj6iqv5mhbh3ggys337ggrcawjx5drxcpkvb4qzc5rgcjp57mvc";
      type = "gem";
    };
    version = "0.6.0";
  };
  fog-json = {
    dependencies = ["fog-core" "multi_json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj8llzc119zafbmfa4ai3z5s7c4vp9akfs0f9l2piyvcarmlkyx";
      type = "gem";
    };
    version = "1.2.0";
  };
  fog-local = {
    dependencies = ["fog-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ba4lln35nryi6dcbz68vxg9ml6v8cc8s8c82f7syfd84bz76x21";
      type = "gem";
    };
    version = "0.6.0";
  };
  fog-powerdns = {
    dependencies = ["fog-core" "fog-json" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y531ag9qcbyb9mq7lxv77rvdz9bc1igaplgv850z4krg9f7pq7m";
      type = "gem";
    };
    version = "0.2.0";
  };
  fog-profitbricks = {
    dependencies = ["fog-core" "fog-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0879dfgdd9xby0l41a0rq0nzj9sj24l34knkjf48rdihvi7pbcl4";
      type = "gem";
    };
    version = "4.1.1";
  };
  fog-radosgw = {
    dependencies = ["fog-core" "fog-json" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nslgv8yp5qkiryj3zsm91gs7s6i626igj61kwxjjwk2yv6swyr6";
      type = "gem";
    };
    version = "0.0.5";
  };
  fog-riakcs = {
    dependencies = ["fog-core" "fog-json" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nbxc4dky3agfwrmgm1aqmi59p6vnvfnfbhhg7xpg4c2cf41whxm";
      type = "gem";
    };
    version = "0.1.0";
  };
  fog-sakuracloud = {
    dependencies = ["fog-core" "fog-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08krsn9sk5sx0aza812g31r169bd0zanb8pq5am3a64j6azarimd";
      type = "gem";
    };
    version = "1.7.5";
  };
  fog-serverlove = {
    dependencies = ["fog-core" "fog-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hxgmwzygrw25rbsy05i6nzsyr0xl7xj5j2sjpkb9n9wli5sagci";
      type = "gem";
    };
    version = "0.1.2";
  };
  fog-softlayer = {
    dependencies = ["fog-core" "fog-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f2crz9g3s6m6casr3bsdqc7lp55gd22iq99r63zi80fx37c1pzf";
      type = "gem";
    };
    version = "1.1.4";
  };
  fog-storm_on_demand = {
    dependencies = ["fog-core" "fog-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fif1x8ci095b2yyilf65n7x6iyvn448azrsnmwsdkriy8vxxv3y";
      type = "gem";
    };
    version = "0.1.1";
  };
  fog-terremark = {
    dependencies = ["fog-core" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01lfkh9jppj0iknlklmwyb7ym3bfhkq58m3absb6rf5a5mcwi3lf";
      type = "gem";
    };
    version = "0.1.0";
  };
  fog-vmfusion = {
    dependencies = ["fission" "fog-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g0l0k9ylxk1h9pzqr6h2ba98fl47lpp3j19lqv4jxw0iw1rqxn4";
      type = "gem";
    };
    version = "0.1.0";
  };
  fog-voxel = {
    dependencies = ["fog-core" "fog-xml"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10skdnj59yf4jpvq769njjrvh2l0wzaa7liva8n78qq003mvmfgx";
      type = "gem";
    };
    version = "0.1.0";
  };
  fog-xml = {
    dependencies = ["fog-core" "nokogiri"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "043lwdw2wsi6d55ifk0w3izi5l1d1h0alwyr3fixic7b94kc812n";
      type = "gem";
    };
    version = "0.1.3";
  };
  formatador = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gc26phrwlmlqrmz4bagq1wd5b7g64avpx0ghxr9xdxcvmlii0l0";
      type = "gem";
    };
    version = "0.2.5";
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
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "038qvz7kd3cfxk8bvagqhakx68pfbnmghpdkx7573wbf0maqp9a3";
      type = "gem";
    };
    version = "0.9.5";
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
  ipaddress = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x86s0s11w202j6ka40jbmywkrx8fhq8xiy8mwvnkhllj57hqr45";
      type = "gem";
    };
    version = "0.8.3";
  };
  jmespath = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d4wac0dcd1jf6kc57891glih9w57552zgqswgy74d1xhgnk0ngf";
      type = "gem";
    };
    version = "1.4.0";
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
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15zplpfw3knqifj9bpf604rb3wc1vhq6363pd6lvhayng8wql5vy";
      type = "gem";
    };
    version = "2.4.0";
  };
  minitest = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0icglrhghgwdlnzzp4jf76b0mbc71s80njn5afyfjn4wqji8mqbq";
      type = "gem";
    };
    version = "5.11.3";
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
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  net-ping = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19p3d39109xvbr4dcjs3g3zliazhc1k3iiw69mgb1w204hc7wkih";
      type = "gem";
    };
    version = "1.7.8";
  };
  net-sftp = {
    dependencies = ["net-ssh"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nsymscb30srnpxa5ml84my9gnfkn8x5hrzad2s0wdvi81j0z3yi";
      type = "gem";
    };
    version = "2.1.0";
  };
  net-ssh = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jglf8rxvlw6is5019r6kwsdhw38zm3z39jbghdbj449r6h7h77n";
      type = "gem";
    };
    version = "5.1.0";
  };
  netrc = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09zll7c6j7xr6wyvh5mm5ncj6pkryp70ybcsxdbw1nyphx5dh184";
      type = "gem";
    };
    version = "1.10.1";
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
      sha256 = "040jf98jpp6w140ghkhw2hvc1qx41zvywx5gj7r2ylr1148qnj7q";
      type = "gem";
    };
    version = "2.0.5";
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
  right_aws = {
    dependencies = ["right_http_connection"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a3l5vyvq078nq976rzkrd6fbj522sbgrxpdq3p9z373h0awha09";
      type = "gem";
    };
    version = "3.1.0";
  };
  right_http_connection = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0shd8v24aqxdvim1gdqzwxpanjhfgkhdaw0m0lzz7sybkb02j8qf";
      type = "gem";
    };
    version = "1.5.0";
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
    dependencies = ["em-http-request" "em-http-server" "eventmachine" "parse-cron" "sensu-extension" "sensu-extensions" "sensu-json" "sensu-logger" "sensu-redis" "sensu-settings" "sensu-spawn" "sensu-transport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rxv6yj63nkxlzmmqk6qpfpcvrbar9s4sd4kgfb5zsv9bw7236cr";
      type = "gem";
    };
    version = "1.6.2";
  };
  sensu-extension = {
    dependencies = ["eventmachine"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bpizp4n01rv72cryjjlrbfxxj3csish3mkxjzdy4inpi5j5h1dw";
      type = "gem";
    };
    version = "1.5.2";
  };
  sensu-extensions = {
    dependencies = ["sensu-extension" "sensu-extensions-check-dependencies" "sensu-extensions-debug" "sensu-extensions-json" "sensu-extensions-occurrences" "sensu-extensions-only-check-output" "sensu-extensions-ruby-hash" "sensu-json" "sensu-logger" "sensu-settings"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04v221qjv8qy3jci40i66p63ig5vrrh0dpgmf1l8229x5m7bxrsg";
      type = "gem";
    };
    version = "1.10.0";
  };
  sensu-extensions-check-dependencies = {
    dependencies = ["sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hc4kz7k983f6fk27ikg5drvxm4a85qf1k07hqssfyk3k75jyj1r";
      type = "gem";
    };
    version = "1.1.0";
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
  sensu-extensions-influxdb2 = {
    dependencies = ["em-http-request" "multi_json" "sensu-extension"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0shq7bmwd47xxsqw2sbd4rldzgk66bn794avv0dg8nc10plcdc91";
      type = "gem";
    };
    version = "0.1.1";
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
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sd8jls3gqws69hbpr37n05y3dfg55zw4csp8dvcnjxxfp0p49d8";
      type = "gem";
    };
    version = "0.2.0";
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
      sha256 = "08zlxg5j3bhs72cc7wcllp026jbif0xiw6ib1cgawndlpsfl9fgx";
      type = "gem";
    };
    version = "2.1.1";
  };
  sensu-logger = {
    dependencies = ["eventmachine" "sensu-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jpw4kz36ilaknrzb3rbkhpbgv93w2d668z2cv395dq30d4d3iwm";
      type = "gem";
    };
    version = "1.2.2";
  };
  sensu-plugin = {
    dependencies = ["json" "mixlib-cli"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jc28i78vqzzhfp371gfa4y87sgzwi56f2lgzd4cdlj0jjyqi6z4";
      type = "gem";
    };
    version = "1.4.6";
  };
  sensu-plugins-aws = {
    dependencies = ["aws-sdk" "aws-sdk-v1" "erubis" "fog" "fog-core" "rest-client" "right_aws" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vjjv5rcc3jk5clyb754kkxixpfixdii3aw77j53190gcx7ih942";
      type = "gem";
    };
    version = "6.3.0";
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
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bprlq3mabq6c56md04j1b1sx90riwmyws8nixarrw6a2bdr7riv";
      type = "gem";
    };
    version = "4.0.0";
  };
  sensu-plugins-dns = {
    dependencies = ["dnsruby" "public_suffix" "sensu-plugin" "whois" "whois-parser"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pqf9w8z4sfj43fr30hxdmnfa1lj2apkc0bm6jz851bmj9bzqahl";
      type = "gem";
    };
    version = "2.1.1";
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
      sha256 = "16pc5q7gain6vf64pfd3rv3kprhyhw3nbc8czsl1al2v3w4yfg17";
      type = "gem";
    };
    version = "1.3.0";
  };
  sensu-plugins-ipmi = {
    dependencies = ["rubyipmi" "sensu-plugin"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "86b469196f519ba4380f7ba00dc2bbd973784970";
      sha256 = "1dznzcfnwzw8dxs1m4408ysmy41hgbklbmm1vhdhjmhwsbsb6wmr";
      type = "git";
      url = "git://github.com/speartail/sensu-plugins-ipmi.git";
    };
    version = "1.0.1";
  };
  sensu-plugins-load-checks = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lgsfvlv8gmd69v8q0mn51vvddp5qaq408ylb0zkqxrlwzydbl3b";
      type = "gem";
    };
    version = "4.0.2";
  };
  sensu-plugins-logs = {
    dependencies = ["sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17shj4msc8bzqgqi5waw649hzzgl8q87z6flmpg0msnmv4r2h1cf";
      type = "gem";
    };
    version = "1.3.2";
  };
  sensu-plugins-mailer = {
    dependencies = ["aws-ses" "erubis" "mail" "mailgun-ruby" "ruby-ntlm" "sensu-plugin"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yxdkrjkdqcqy7829m38zm0imwgqnb0242hszlq4b68b695c0y9l";
      type = "gem";
    };
    version = "2.1.0";
  };
  sensu-plugins-network-checks = {
    dependencies = ["activesupport" "dnsbl-client" "net-ping" "sensu-plugin" "whois" "whois-parser"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "6ef23ef2c0af032421bf9519d5d4a53153eab6b3";
      sha256 = "0x41p52i8qynasfnavy357z876h1ik9bvmvcfg1l8ihbyy7zzzp0";
      type = "git";
      url = "git://github.com/speartail/sensu-plugins-network-checks.git";
    };
    version = "3.2.1";
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
      sha256 = "162a73nfgqzfny6pc9y9fv9an35cc0ddw20h7gv6cikh95ilnapn";
      type = "gem";
    };
    version = "4.1.1";
  };
  sensu-plugins-raid-checks = {
    dependencies = ["english" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b5ab8bkrffiyzzlwspakprxcwxq9yhzav8rfjb4l60cdkz403dz";
      type = "gem";
    };
    version = "2.0.2";
  };
  sensu-plugins-redis = {
    dependencies = ["redis" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00v78jp08wfqlrwmrvmq6q297dj5qs7mzn1bzcn6dwz1c4ibbrm4";
      type = "gem";
    };
    version = "3.0.1";
  };
  sensu-plugins-sensu = {
    dependencies = ["chronic_duration" "rest-client" "sensu-plugin"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16xcyf160xii97nn22r0djga0ljj6wgbdfx28c08gqnrixslw2zs";
      type = "gem";
    };
    version = "2.5.0";
  };
  sensu-plugins-sftp = {
    dependencies = ["net-sftp" "sensu-plugin"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sq7ca83dbraa3id1pyhxfxs3zjb6chd34zvm5wxw2p0z3780ca1";
      type = "gem";
    };
    version = "1.0.1";
  };
  sensu-plugins-snmp = {
    dependencies = ["sensu-plugin" "snmp"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18xmnl1rhl83v0akynphh1pmg09clgjqwj9bl30g5fss1qpqma5b";
      type = "gem";
    };
    version = "2.1.0";
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
      sha256 = "053h0j74q56nd8p5q3sls40hci6ii16xvv7b0a4l9ljw2x6m0dkh";
      type = "gem";
    };
    version = "2.0.0";
  };
  sensu-redis = {
    dependencies = ["eventmachine"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0widfmmj1h9ca2kk14wy1sqmlkq40linp89a73s3ghngnzri0xyk";
      type = "gem";
    };
    version = "2.4.0";
  };
  sensu-settings = {
    dependencies = ["parse-cron" "sensu-json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "152n4hazv2l4vbzrgd316rpj135jmz042fyh6k2yv2kw0x29pi0f";
      type = "gem";
    };
    version = "10.14.0";
  };
  sensu-spawn = {
    dependencies = ["childprocess" "em-worker" "eventmachine" "ffi"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17yc8ivjpjbvig9r7yl6991d6ma0kcq75fbpz6i856ljvcr3lmd5";
      type = "gem";
    };
    version = "2.5.0";
  };
  sensu-transport = {
    dependencies = ["amq-protocol" "amqp" "eventmachine" "sensu-redis"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x6vyfmg1jm1srf7xa5aka73by7qwcmry2rx8kq8phwa4g0v4mzr";
      type = "gem";
    };
    version = "8.2.0";
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
      sha256 = "1fjx9j327xpkkdlxwmkl3a8wqj7i4l4jwlrv3z13mg95z9wl253z";
      type = "gem";
    };
    version = "1.2.5";
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
      sha256 = "06p1i6qhy34bpb8q8ms88y6f2kz86azwm098yvcc0nyqk9y729j1";
      type = "gem";
    };
    version = "0.0.7.5";
  };
  whois = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nrcldii7g3ncgrihhm7hymbqqp45qkjylz4rcjxw6wkjgb7mq00";
      type = "gem";
    };
    version = "4.0.7";
  };
  whois-parser = {
    dependencies = ["activesupport" "whois"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "9db810d187a97175c3b28edd100c4edd07d683f2";
      sha256 = "0py9fhvwr81nqi4z8gxrkn5r6y71pbmaa6pv709qiqwwshzzha76";
      type = "git";
      url = "git://github.com/weppos/whois-parser.git";
    };
    version = "1.1.0";
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