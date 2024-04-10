package com.example.focus2
//import android.content.Intent
//import android.os.Bundle
//import androidx.appcompat.app.AppCompatActivity
//import androidx.core.content.ContextCompat
//import com.example.focus2.R
//
//class MainActivity : AppCompatActivity() {
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_main)
//
//        val serviceIntent = Intent(this, LocationService::class.java)
//        ContextCompat.startForegroundService(this, serviceIntent)
//    }
//}

import android.Manifest
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.startActivity

fun checkForPermission(context: Context): Boolean {
    val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
    val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
    if (mode != AppOpsManager.MODE_ALLOWED) {
        context.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
        Log.d("MainActivity", "Usage stats permission not granted")
        return true
    }
    Log.d("MainActivity", "Usage stats permission granted")
    return false
}

class MainActivity : AppCompatActivity() {

    private val locationPermissions = arrayOf(
        Manifest.permission.ACCESS_FINE_LOCATION,
        Manifest.permission.ACCESS_COARSE_LOCATION,
        Manifest.permission.ACCESS_BACKGROUND_LOCATION
    )

    private val locationRequestCode = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        checkForPermission(this)
//        if (checkForPermission(this)) {
//            val usageStatsList = getAppUsa
//        }
        startLocationService()
    }

    private fun hasLocationPermission(): Boolean {
        for (permission in locationPermissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    private fun requestLocationPermission() {
        Log.d("MainActivity", "Requesting location permission")
        ActivityCompat.requestPermissions(this, locationPermissions, locationRequestCode)
        Log.d("MainActivity", "Location permission requested hererefedf")
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == locationRequestCode) {
            if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startLocationService()
            } else {
requestLocationPermission()
            }
        }
    }

    private fun startLocationService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        Log.d("MainActivity", "Starting location service")
  ContextCompat.startForegroundService(this, serviceIntent)    }
}