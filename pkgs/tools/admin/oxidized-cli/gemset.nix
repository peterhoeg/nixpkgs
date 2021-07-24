{
  asetus = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zkr8cbp8klanqmhzz7qmimzlxh6zmsy98zb3s75af34l7znq790";
      type = "gem";
    };
    version = "0.3.0";
  };
  net-ssh = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "101wd2px9lady54aqmkibvy4j62zk32w0rjz4vnigyg974fsga40";
      type = "gem";
    };
    version = "5.2.0";
  };
  net-telnet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13qxznpwmc3hs51b76wqx2w29r158gzzh8719kv2gpi56844c8fx";
      type = "gem";
    };
    version = "0.1.1";
  };
  oxidized = {
    dependencies = ["asetus" "net-ssh" "net-telnet" "rugged" "slop"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07hpxmdjkfpkc00ln3hhh5qkj0lyhcmgbi0jza2c8cnjyy9sc73x";
      type = "gem";
    };
    version = "0.26.3";
  };
  oxidized-script = {
    dependencies = ["oxidized" "slop"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15cxsyaz2mwd7jj63gfv3lzyqkvb3gz29wxfy7xyjdzkc19c7vk6";
      type = "gem";
    };
    version = "0.6.0";
  };
  rugged = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04rkxwzaa6897da3mnm70g720gpxwyh71krfn6ag1dkk80x8a8yz";
      type = "gem";
    };
    version = "0.99.0";
  };
  slop = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00w8g3j7k7kl8ri2cf1m58ckxk8rn350gp4chfscmgv6pq1spk3n";
      type = "gem";
    };
    version = "3.6.0";
  };
}
