+++
date = "2017-09-02T18:22:47+08:00"
title = "Add float debug button for react native"
tags = ["android", "react", "react-native"]
+++

React-native 里面在模拟器里面可以通过快捷键打开开发菜单，在设备里面可以通过摇晃设备打开开发菜单。但是摇晃有时候并不是一个好的操作，比如是个 pad，或者比如你自己的设备本身会触发晃动动作。那么如何在开发模式下面增加一个按钮打开这个菜单呢？可惜官方对这个功能没有兴趣多做开发 https://github.com/facebook/react-native/issues/10191 。

## iOS

ios 里面直接就把这个接口暴露出来了，可以直接在 js 里面调用。

```javascript
import {NativeModules} from 'react-native';

// 在某个按钮的动作里面
const {DevMenu} = NativeModules;
DevMenu.show();
```

## Android

iOS 是 react-native 的亲儿子，Android 里面并没有那么方便的方法，得自己通过 native 代码加。

下面两种方式加的都是 `android.support.design.widget.FloatingActionButton` 按钮，其它的类似。需要增加好编译依赖 `compile 'com.android.support:design:23.0.0'`，版本号按照自己的修改下。

```java
        private void addDevButton() {

            MainApplication application = (MainApplication) getApplication();
            ReactNativeHost reactNativeHost = application.getReactNativeHost();
            ReactInstanceManager reactInstanceManager = reactNativeHost.getReactInstanceManager();
            final DevSupportManager devSupportManager = reactInstanceManager.getDevSupportManager();

            // 这里是增加一个自定义菜单
//            devSupportManager.addCustomDevOption("Custom dev option", new DevOptionHandler() {
//                @Override
//                public void onOptionSelected() {
//                    Toast.makeText(MainActivity.this, "Hello from custom dev option", Toast.LENGTH_SHORT).show();
//                }
//            });


            // Fake empty container dev_button_layout
            // 创建一个 layout
            RelativeLayout lContainerLayout = new RelativeLayout(mActivity.getApplicationContext());
            lContainerLayout.setLayoutParams(new RelativeLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT , ViewGroup.LayoutParams.MATCH_PARENT ));

            // custom view
            // 创建一个 button
            FloatingActionButton button = new FloatingActionButton(mActivity);
            button.setImageResource(R.drawable.ga_airplane);

            RelativeLayout.LayoutParams lButtonParams = new RelativeLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
            );
            lButtonParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            lButtonParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            button.setLayoutParams(lButtonParams);

            ViewGroup.MarginLayoutParams mp = (ViewGroup.MarginLayoutParams) button.getLayoutParams();
            mp.setMargins(0, 0, 0, dpToPx(mActivity, 125));

            button.setLayoutParams(mp);

            //设定拖动动作
            button.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    switch (event.getActionMasked()) {
                        case MotionEvent.ACTION_DOWN:
                            dX = v.getX() - event.getRawX();
                            dY = v.getY() - event.getRawY();
                            lastAction = MotionEvent.ACTION_DOWN;
                            break;

                        case MotionEvent.ACTION_MOVE:
                            v.setY(event.getRawY() + dY);
                            v.setX(event.getRawX() + dX);
                            lastAction = MotionEvent.ACTION_MOVE;
                            break;

                        case MotionEvent.ACTION_UP:
                            if (lastAction == MotionEvent.ACTION_DOWN)
                                // 点击的时候打开菜单
                                devSupportManager.showDevOptionsDialog();
                            break;

                        default:
                            return false;
                    }
                    return true;
                }
            });

            lContainerLayout.addView(button);
            addContentView(lContainerLayout, new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT , ViewGroup.LayoutParams.MATCH_PARENT ));
        }
```

上面是纯代码方式，还可以通过 xml 文件方式搞定。

新建一个 layout 文件，取名比如叫做 `dev_button_layout.xml`， rootTag 是 `RelativeLayout`。然后在里面添加一个 `FloatingActionButton`，id 设置为 `dev_button`，然后设置好属性和位置。

```java
        private void addDevButton() {
            MainApplication application = (MainApplication) getApplication();
            ReactNativeHost reactNativeHost = application.getReactNativeHost();
            ReactInstanceManager reactInstanceManager = reactNativeHost.getReactInstanceManager();
            final DevSupportManager devSupportManager = reactInstanceManager.getDevSupportManager();

            View view = View.inflate(mActivity, R.layout.dev_button_layout, null);
            FloatingActionButton button = (FloatingActionButton) view.findViewById(R.id.dev_button);
            //button.setImageResource(R.drawable.ga_airplane);

            button.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    switch (event.getActionMasked()) {
                        case MotionEvent.ACTION_DOWN:
                            dX = v.getX() - event.getRawX();
                            dY = v.getY() - event.getRawY();
                            lastAction = MotionEvent.ACTION_DOWN;
                            break;

                        case MotionEvent.ACTION_MOVE:
                            v.setY(event.getRawY() + dY);
                            v.setX(event.getRawX() + dX);
                            lastAction = MotionEvent.ACTION_MOVE;
                            break;

                        case MotionEvent.ACTION_UP:
                            if (lastAction == MotionEvent.ACTION_DOWN)
                                devSupportManager.showDevOptionsDialog();
                            break;

                        default:
                            return false;
                    }
                    return true;
                }
            });

            addContentView(view, new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT , ViewGroup.LayoutParams.MATCH_PARENT ));
        }
```


然后在你的 `MainActivity` 的 `onCreate` 里面，在 `super.onCreate(savedInstanceState);` 后面增加

```
            // debug 环境下才显示
            if(BuildConfig.DEBUG)
                addDevButton();
```


