//
//  LiveViewRFCOMM.m
//  
//
//  Created by Ari on 3/31/11.
//  Copyright 2011 Squish Software. All rights reserved.
//

#import "LVController.h"

#define RFCOMM_EVENT_OPEN_CHANNEL_COMPLETE                 0x80
	
// data: event(8), len(8), rfcomm_cid(16)
#define RFCOMM_EVENT_CHANNEL_CLOSED                        0x81
	
// data: event (8), len(8), address(48), channel (8), rfcomm_cid (16)
#define RFCOMM_EVENT_INCOMING_CONNECTION                   0x82
	
// data: event (8), len(8), rfcommid (16), ...
#define RFCOMM_EVENT_REMOTE_LINE_STATUS                    0x83
	
// data: event(8), len(8), rfcomm_cid(16), credits(8)
#define RFCOMM_EVENT_CREDITS			                   0x84
	
// data: event(8), len(8), status (8), rfcomm server channel id (8) 
#define RFCOMM_EVENT_SERVICE_REGISTERED                    0x85
    
// data: event(8), len(8), status (8), rfcomm server channel id (8) 
#define RFCOMM_EVENT_PERSISTENT_CHANNEL                    0x86

bd_addr_t addr = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00}; 
uint16_t source_cid;
char PIN[] = "0000";

void packet_handler(uint8_t packet_type, uint16_t channel, uint8_t *packet, uint16_t size);

void runBluetooth(char *MACAddr) {
	sscan_bd_addr((uint8_t *)MACAddr, addr);
	run_loop_init(RUN_LOOP_POSIX);
	int error = bt_open();
	if (error) {
		printf("Failed to open connection to BTdaemon. Error %d.\n", error);
        [[LVController sharedInstance] setStatus:@"BTdaemon failed." withExit:TRUE];
		return;
	}
	bt_register_packet_handler(packet_handler);
	bt_send_cmd(&btstack_set_power_mode, HCI_POWER_ON);
	[[LVController sharedInstance] setStatus:@"Initializing..." withExit:FALSE];
	run_loop_execute();
	bt_close();
}

void LVSendRawData(uint8_t *data, uint16_t len) {
    bt_send_rfcomm(source_cid, data, len);
}

void packet_handler(uint8_t packet_type, uint16_t channel, uint8_t *packet, uint16_t size){
	bd_addr_t event_addr;
	
	switch (packet_type) {
		case RFCOMM_DATA_PACKET:
			//printf("Received RFCOMM data on channel id %u, size %u\n", channel, size);
			//hexdump(packet, size);
            [[LVController sharedInstance] processData:packet length:size];
			break;
			
		case HCI_EVENT_PACKET:
			switch (packet[0]) {
				case BTSTACK_EVENT_POWERON_FAILED:
					printf("HCI init failed - make sure you have Bluetooth turned off in Settings.\n");
					[[LVController sharedInstance] setStatus:@"Initialization failed." withExit:TRUE];
					[[LVController sharedInstance] setInitialized:FALSE];
					break;		
					
				case BTSTACK_EVENT_STATE:
                    if (packet[2] == HCI_STATE_WORKING) {
                        printf("BTstack activated.\n");
                        [[LVController sharedInstance] setInitialized:TRUE];
                        [[LVController sharedInstance] setStatus:@"Connecting..." withExit:FALSE];
						bt_send_cmd(&rfcomm_create_channel, addr, 1);
					}
					break;
                    
				case HCI_EVENT_PIN_CODE_REQUEST:
					printf("Pairing using PIN 0000.\n");
					bt_flip_addr(event_addr, &packet[2]); 
					bt_send_cmd(&hci_pin_code_request_reply, &event_addr, 4, "0000");
					break;
                    
				case RFCOMM_EVENT_OPEN_CHANNEL_COMPLETE:
                    // event: 0, len: 1, status: 2, address: 3, handle: 9, server channel: 11, rfcomm_cid: 12, max frame size: 14
					if (packet[2]) {
						printf("RFCOMM channel open failed with status %u.\n", packet[2]);
                        [[LVController sharedInstance] setStatus:@"Connection failed." withExit:TRUE];
					} else {
						source_cid = READ_BT_16(packet, 12);
						channel_mtu = READ_BT_16(packet, 14);
						printf("RFCOMM channel open succeeded. New RFCOMM Channel ID: %u, mtu: %u.\n", source_cid, channel_mtu);
                        [[LVController sharedInstance] sendGetCaps];
                        [[LVController sharedInstance] setConnected:TRUE];
                        [[LVController sharedInstance] setStatus:@"Connected." withExit:FALSE];
					}
					break;
                    
				case HCI_EVENT_DISCONNECTION_COMPLETE:
					printf("Basebank connection closed\n");
                    [[LVController sharedInstance] setStatus:@"Connection closed." withExit:TRUE];
					[[LVController sharedInstance] setConnected:FALSE];
					break;
                    
				default:
					break;
			}
			break;
		default:
			break;
	}
}