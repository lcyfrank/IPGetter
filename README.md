# IPGetter
Get other connectable IP in subnet of HotPost.

Use the *SimplePing* provided by *Apple*.

### How to use

##### First step:

add header file.

```objc
#import "SGIPGetter.h"
```

##### Second step:

```objc
[[SGIPGetter shared] sg_getDeviceIP:^(NSArray<NSString *> *ips) {
    NSLog(@"%@", ips);
}];
```

### Configure timeout

Now you can configure the timeout of each ping operation.

```objc
[[SGIPGetter shared] configureTimeoutOfEachPing:0.5];
```

### Refresh

This IPGetter will cache the IPs you got automatically, so call the *refresh* method before you get IPs when network environment has changed.

```objc
[[SGIPGetter shared] refresh];
```
