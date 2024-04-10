package com.example.focus2
import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.firebase.storage.FirebaseStorage
import org.json.JSONObject
import java.io.File
import java.util.Timer

class LocationService : Service() {

    private lateinit var notificationManager: NotificationManager
    private val channelId = "location_notification_channel"
    private val handler = Handler(Looper.getMainLooper())
    private val runnableCode = object : Runnable {
        override fun run() {
            updateNotification()
            handler.postDelayed(this, 60000)
        }
    }
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Location Service")
            .setContentText("Running...")
            .setSmallIcon(R.drawable.ic_notification)
            .build()

        startForeground(1, notification)

        // your code here
        startForegroundService()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(runnableCode)
    }

    private fun startForegroundService() {
        Log.d("LocationService", "startForegroundService() called")
        notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val resultIntent = Intent()
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            0,
            resultIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                channelId,
                "Location Service",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(notificationChannel)
        }
        //repeat updateNotification every 10 seconds
        handler.post(runnableCode)



    }

    private fun getAppUsageStats(): List<UsageStats> {
        val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        val oneHourAgo = currentTime - 60 * 60 * 1000
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            oneHourAgo,
            currentTime
        )
        return usageStatsList
    }
    fun displayUsageStats(): String {
        val usageStatsList = getAppUsageStats()
        var usageString = ""
        for (usageStats in usageStatsList) {
            if (usageStats.packageName in listOf("com.google.android.youtube", "com.google.android.apps.maps", "com.google.android.apps.photos", "com.google.android.apps.docs", "com.google.android.apps.tachyon"))
            {

                Log.d("UsageStats", "Package Name: ${usageStats.packageName}")
                Log.d("UsageStats", "First Time Used: ${usageStats.firstTimeStamp}")
                Log.d("UsageStats", "Last Time Used: ${usageStats.lastTimeStamp}")
                Log.d("UsageStats", "Total Time Used: ${usageStats.totalTimeInForeground}")
                usageString += "Package Name: ${usageStats.packageName}\n"
                usageString += "First Time Used: ${usageStats.firstTimeStamp}\n"
                usageString += "Last Time Used: ${usageStats.lastTimeStamp}\n"
                usageString += "Total Time Used: ${usageStats.totalTimeInForeground}\n"
            }
        }
        return usageString
    }
    private fun updateNotification() {
        Log.d("LocationService", "updateNotification() called")
        val usage = displayUsageStats()
        val latitude = "Latitude: "
        val longitude = "Longitude:"
        println(latitude.toString())
        println(longitude.toString())
        val jsonObject = JSONObject()
        //get current tim,e
        val currentTime = System.currentTimeMillis()
        jsonObject.put("time", currentTime)
        jsonObject.put("latitude", latitude)
        jsonObject.put("longitude", longitude)
        jsonObject.put("usage", usage)
        val jsonString = jsonObject.toString()
        val file = File.createTempFile("temp",".json")
        file.writeText(jsonString)
        val storageReference = FirebaseStorage.getInstance().reference
        val jsonFileReference = storageReference.child("json/${file.name}")
        var fileUri = Uri.fromFile(file)
        jsonFileReference.putFile(fileUri)
            .addOnSuccessListener {
                Log.d("LocationService", "File uploaded successfully")
            }
            .addOnFailureListener {
                Log.d("LocationService", "File upload failed")
            }
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setOngoing(true)
            .setContentTitle("Current Location")
            .setContentText("Lat: , Lon:")
            .setPriority(NotificationCompat.PRIORITY_MAX)  // Set the priority to max
            .setWhen(System.currentTimeMillis())

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH  // Set the importance to high
            val channel = NotificationChannel(channelId, "Location Service", importance)
            notificationManager.createNotificationChannel(channel)
            notificationBuilder.setChannelId(channelId)
        }

        startForeground(1, notificationBuilder.build())
    }}