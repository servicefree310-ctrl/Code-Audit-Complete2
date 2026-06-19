package com.zebvix.exchange.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Receives BOOT_COMPLETED and MY_PACKAGE_REPLACED broadcasts.
 * Declared in AndroidManifest.xml — re-schedules any WorkManager tasks
 * (price alerts, sync) that were cancelled when the device rebooted.
 * The actual rescheduling is handled by WorkManager's own boot receiver;
 * this stub satisfies the manifest declaration.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // WorkManager reschedules its own tasks on boot automatically.
        // Add any custom rescheduling logic here if needed in future.
    }
}
