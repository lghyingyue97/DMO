package com.lianke.dmo;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import java.lang.reflect.Field;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        addTranslucentStatusFlag(this);
        super.onCreate(savedInstanceState);
        makeStatusBarTranslucent(this);
    }

    public static void addTranslucentStatusFlag(Activity ac) {
        //5.x状态栏沉浸 减少启动界面状态栏变化
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            ac.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    public static void makeStatusBarTranslucent(Activity ac) {
        //5.x状态栏沉浸
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = ac.getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);//必须设置
        }

        //去掉 7.x上的蒙层
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                @SuppressLint("PrivateApi") Class decorViewClazz = Class.forName("com.android.internal.policy.DecorView");
                Field field = decorViewClazz.getDeclaredField("mSemiTransparentStatusBarColor");
                field.setAccessible(true);
                field.setInt(ac.getWindow().getDecorView(), Color.TRANSPARENT);  //改为透明
            } catch (Exception e) {

            }
        }
    }

}
