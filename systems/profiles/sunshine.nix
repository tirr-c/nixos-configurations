{ pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };
  boot.initrd.kernelModules = ["uhid"];
  services.udev.packages = [
    (
      pkgs.runCommand "udev-uhid-uaccess" {} ''
        mkdir -p $out/lib/udev/rules.d
        cat >$out/lib/udev/rules.d/70-uhid-uaccess.rules <<EOF
        KERNEL=="uhid", TAG+="uaccess"
        EOF
      ''
    )
  ];

  # Dummy EDID for DP output, supports 4K ~120Hz
  hardware.display.edid.packages = [
    (
      pkgs.runCommand "edid-custom" {} ''
        mkdir -p $out/lib/firmware/edid
        base64 -d >$out/lib/firmware/edid/acer-xv273k-dp1 <<EOF
        AP///////wAEcrEGU48AhTIcAQS1PCJ4OycRrFE1tSYOUFQjSACBQIGAgcCBAJUAswDRwAEBTdAA
        oPBwPoAwIDUAVVAhAAAatGYAoPBwH4AIIBgEVVAhAAAaAAAA/QwwkP//awEKICAgICAgAAAA/ABY
        VjI3M0sKICAgICAgAiECA0jxUQEDBBITBRQfkAcCXV5fYGE/IwkHB4MBAADiAMBtAwwAEAA4eCAA
        YAECA2gaAAABATCQAOMF4wHkDwDAAOYGBwFhVhwHgoBUcDhNQAgg+AxWUCEAABpA5wBqoKBqUAgg
        mARVUCEAABpvwgCgoKBVUDAgNQBVUCEAAB4AwHASeQAAAwEomqABhP8OoAAvgCEAbwg+AAMABQDg
        9gAEfwdZAC+AHwBvCBkAAQADACYACAcHAwPgfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJSQ
        EOF
      ''
    )
  ];
}
