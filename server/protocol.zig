const std = @import("std");
const data_tables = @import("data_tables.zig");

pub const PacketHeader = extern struct {
    len: u32,
    mid: u32,
    tag: u32,
    user_id: u32,
};

pub const MSGID = struct {
    pub const HEARTBEAT: u32 = 1000;
    pub const CLIENT_VERIFY_REQ: u32 = 1001;
    pub const CLIENT_VERIFY_ACK: u32 = 1002;
    pub const CLIENT_VERIFY_NTF: u32 = 1003;
    pub const CLIENT_GOODS_REQ: u32 = 1004;
    pub const CLIENT_GOODS_ACK: u32 = 1005;
    pub const CLIENT_GOODS_NTF: u32 = 1006;
    pub const CLIENT_PVE_BATTLE_REQ: u32 = 1007;
    pub const CLIENT_PVE_BATTLE_ACK: u32 = 1008;
    pub const CLIENT_PVE_BATTLE_NTF: u32 = 1009;
    pub const CLIENT_LEVEL_INFO_REQ: u32 = 1010;
    pub const CLIENT_LEVEL_INFO_ACK: u32 = 1011;
    pub const CLIENT_LEVEL_INFO_NTF: u32 = 1012;
    pub const CLIENT_RECRUIT_REQ: u32 = 1013;
    pub const CLIENT_RECRUIT_ACK: u32 = 1014;
    pub const CLIENT_RECRUIT_NTF: u32 = 1015;
    pub const CLIENT_SIGN_IN_REQ: u32 = 1016;
    pub const CLIENT_SIGN_IN_ACK: u32 = 1017;
    pub const CLIENT_SIGN_IN_NTF: u32 = 1018;
    pub const CLIENT_TASK_PERFORM_REQ: u32 = 1019;
    pub const CLIENT_TASK_PERFORM_ACK: u32 = 1020;
    pub const CLIENT_TASK_PERFORM_NTF: u32 = 1021;
    pub const CLIENT_ACTIVITY_GET_REQ: u32 = 1292;
    pub const CLIENT_ACTIVITY_GET_ACK: u32 = 1293;
    pub const CLIENT_ACTIVITY_GET_NTF: u32 = 1294;
    pub const CLIENT_LIMIT_SIGN_REQ: u32 = 2064;
    pub const CLIENT_LIMIT_SIGN_ACK: u32 = 2065;
    pub const CLIENT_LIMIT_SIGN_NTF: u32 = 2066;
    pub const CLIENT_GET_GIFT_INFO_REQ: u32 = 2038;
    pub const CLIENT_GET_GIFT_INFO_ACK: u32 = 2039;
    pub const CLIENT_GET_GIFT_INFO_NTF: u32 = 2040;
    pub const CLIENT_BINGO_INFO_REQ: u32 = 2224;
    pub const CLIENT_BINGO_INFO_ACK: u32 = 2225;
    pub const CLIENT_BINGO_INFO_NTF: u32 = 2226;
    pub const CLIENT_UPDATE_PAY_PACK_REQ: u32 = 10012;
    pub const CLIENT_UPDATE_PAY_PACK_ACK: u32 = 10013;
    pub const CLIENT_SET_LEVEL_STAR_REQ: u32 = 1040;
    pub const CLIENT_SET_LEVEL_STAR_ACK: u32 = 1041;
    pub const CLIENT_SET_LEVEL_STAR_NTF: u32 = 1042;
    pub const CLIENT_TEAM_SAVE_REQ: u32 = 1130;
    pub const CLIENT_TEAM_SAVE_ACK: u32 = 1131;
    pub const CLIENT_TEAM_SAVE_NTF: u32 = 1132;
    pub const CLIENT_TEAM_SAVE_LEGACY_REQ: u32 = 1046;
    pub const CLIENT_TEAM_SAVE_LEGACY_ACK: u32 = 1047;
    pub const CLIENT_TEAM_SAVE_LEGACY_NTF: u32 = 1048;
    pub const CLIENT_BATTLE_SUPPORT_REQ: u32 = 1277;
    pub const CLIENT_BATTLE_SUPPORT_ACK: u32 = 1278;
    pub const CLIENT_BATTLE_SUPPORT_NTF: u32 = 1279;
    pub const CLIENT_CHOOSE_BATTLE_REWARD_REQ: u32 = 1280;
    pub const CLIENT_CHOOSE_BATTLE_REWARD_ACK: u32 = 1281;
    pub const CLIENT_CHOOSE_BATTLE_REWARD_NTF: u32 = 1282;
    pub const CLIENT_SET_LEVEL_STAR_EX_REQ: u32 = 1283;
    pub const CLIENT_SET_LEVEL_STAR_EX_ACK: u32 = 1284;
    pub const CLIENT_SET_LEVEL_STAR_EX_NTF: u32 = 1285;
    pub const CLIENT_TOWER_REWARD_REQ: u32 = 1298;
    pub const CLIENT_TOWER_REWARD_ACK: u32 = 1299;
    pub const CLIENT_TOWER_REWARD_NTF: u32 = 1300;
    pub const CLIENT_TOWER_BATTLE_REQ: u32 = 1301;
    pub const CLIENT_TOWER_BATTLE_ACK: u32 = 1302;
    pub const CLIENT_TOWER_BATTLE_NTF: u32 = 1303;
    pub const CLIENT_GUIDE_REWARD_REQ: u32 = 1304;
    pub const CLIENT_GUIDE_REWARD_ACK: u32 = 1305;
    pub const CLIENT_GUIDE_REWARD_NTF: u32 = 1306;
    pub const CLIENT_GUIDE_BATTLE_REQ: u32 = 1307;
    pub const CLIENT_GUIDE_BATTLE_ACK: u32 = 1308;
    pub const CLIENT_GUIDE_BATTLE_NTF: u32 = 1309;
    pub const CLIENT_GET_RAND_SHOP_ITEM_REQ: u32 = 1310;
    pub const CLIENT_GET_RAND_SHOP_ITEM_ACK: u32 = 1311;
    pub const CLIENT_GET_RAND_SHOP_ITEM_NTF: u32 = 1312;
    pub const CLIENT_BUY_RAND_SHOP_ITEM_REQ: u32 = 1313;
    pub const CLIENT_BUY_RAND_SHOP_ITEM_ACK: u32 = 1314;
    pub const CLIENT_BUY_RAND_SHOP_ITEM_NTF: u32 = 1315;

    // Currency exchange & general shop
    pub const CLIENT_BUY_GOODS_REQ: u32 = 1088;
    pub const CLIENT_BUY_GOODS_ACK: u32 = 1089;
    pub const CLIENT_BUY_GOODS_NTF: u32 = 1090;

    // Mailbox system
    pub const CLIENT_EMAIL_DATA_REQ: u32 = 1070;
    pub const CLIENT_EMAIL_DATA_ACK: u32 = 1071;
    pub const CLIENT_EMAIL_DATA_NTF: u32 = 1072;
    pub const CLIENT_EMAIL_GOODS_REQ: u32 = 1073;
    pub const CLIENT_EMAIL_GOODS_ACK: u32 = 1074;
    pub const CLIENT_EMAIL_GOODS_NTF: u32 = 1075;
    pub const CLIENT_EMAIL_DELETE_REQ: u32 = 1076;
    pub const CLIENT_EMAIL_DELETE_ACK: u32 = 1077;
    pub const CLIENT_EMAIL_DELETE_NTF: u32 = 1078;
    pub const CLIENT_EMAIL_GOODS_ALL_REQ: u32 = 1079;
    pub const CLIENT_EMAIL_GOODS_ALL_ACK: u32 = 1080;
    pub const CLIENT_EMAIL_GOODS_ALL_NTF: u32 = 1081;
    pub const CLIENT_EMAIL_DELETE_ALL_REQ: u32 = 1082;
    pub const CLIENT_EMAIL_DELETE_ALL_ACK: u32 = 1083;
    pub const CLIENT_EMAIL_DELETE_ALL_NTF: u32 = 1084;
    pub const CLIENT_EMAIL_LOOK_REQ: u32 = 1103;
    pub const CLIENT_EMAIL_LOOK_ACK: u32 = 1104;
    pub const CLIENT_EMAIL_LOOK_NTF: u32 = 1105;

    // Task & Achievement
    pub const CLIENT_TASK_GET_REQ: u32 = 1106;
    pub const CLIENT_TASK_GET_ACK: u32 = 1107;
    pub const CLIENT_TASK_GET_NTF: u32 = 1108;

    // Hero Progression
    pub const CLIENT_HERO_STAR_REQ: u32 = 1022;
    pub const CLIENT_HERO_STAR_ACK: u32 = 1023;
    pub const CLIENT_HERO_STAR_NTF: u32 = 1024;
    pub const CLIENT_HERO_LEVEL_UP_REQ: u32 = 1025;
    pub const CLIENT_HERO_LEVEL_UP_ACK: u32 = 1026;
    pub const CLIENT_HERO_LEVEL_UP_NTF: u32 = 1027;
    pub const CLIENT_HERO_DATA_REQ: u32 = 1028;
    pub const CLIENT_HERO_DATA_ACK: u32 = 1029;
    pub const CLIENT_HERO_DATA_NTF: u32 = 1030;
    pub const CLIENT_HERO_SKILL_UP_REQ: u32 = 1031;
    pub const CLIENT_HERO_SKILL_UP_ACK: u32 = 1032;
    pub const CLIENT_HERO_SKILL_UP_NTF: u32 = 1033;

    // Friend Info
    pub const CLIENT_GET_FRIEND_INFO_REQ: u32 = 1238;
    pub const CLIENT_GET_FRIEND_INFO_ACK: u32 = 1239;
    pub const CLIENT_GET_FRIEND_INFO_NTF: u32 = 1240;

    // Stage Sweep
    pub const CLIENT_SWEEP_LEVEL_STAR_REQ: u32 = 1220;
    pub const CLIENT_SWEEP_LEVEL_STAR_ACK: u32 = 1221;
    pub const CLIENT_SWEEP_LEVEL_STAR_NTF: u32 = 1222;

    // Profile & Personalization
    pub const CLIENT_CHOOSE_MENU_ROLE_REQ: u32 = 1094;
    pub const CLIENT_CHOOSE_MENU_ROLE_ACK: u32 = 1095;
    pub const CLIENT_CHOOSE_MENU_ROLE_NTF: u32 = 1096;
    pub const CLIENT_CHOOSE_NIKE_REQ: u32 = 1097;
    pub const CLIENT_CHOOSE_NIKE_ACK: u32 = 1098;
    pub const CLIENT_CHOOSE_NIKE_NTF: u32 = 1099;
    pub const CLIENT_SET_TITLE_REQ: u32 = 1100;
    pub const CLIENT_SET_TITLE_ACK: u32 = 1101;
    pub const CLIENT_SET_TITLE_NTF: u32 = 1102;
    pub const CLIENT_SET_HEAD_REQ: u32 = 1166;
    pub const CLIENT_SET_HEAD_ACK: u32 = 1167;
    pub const CLIENT_SET_HEAD_NTF: u32 = 1168;
    pub const CLIENT_SET_HEAD_FRAME_REQ: u32 = 1169;
    pub const CLIENT_SET_HEAD_FRAME_ACK: u32 = 1170;
    pub const CLIENT_SET_HEAD_FRAME_NTF: u32 = 1171;
    pub const CLIENT_SET_SIGNATURE_REQ: u32 = 1172;
    pub const CLIENT_SET_SIGNATURE_ACK: u32 = 1173;
    pub const CLIENT_SET_SIGNATURE_NTF: u32 = 1174;
    pub const CLIENT_GET_HIGH_LADDER_BASE_REQ: u32 = 1175;
    pub const CLIENT_GET_HIGH_LADDER_BASE_ACK: u32 = 1176;
    pub const CLIENT_GET_HIGH_LADDER_BASE_NTF: u32 = 1177;
    pub const CLIENT_FRIEND_SUPPORT_GET_REQ: u32 = 1247;
    pub const CLIENT_FRIEND_SUPPORT_GET_ACK: u32 = 1248;
    pub const CLIENT_FRIEND_SUPPORT_GET_NTF: u32 = 1249;
    pub const CLIENT_CHANGE_BIRTHDAY_REQ: u32 = 1387;
    pub const CLIENT_CHANGE_BIRTHDAY_ACK: u32 = 1388;
    pub const CLIENT_CHANGE_BIRTHDAY_NTF: u32 = 1389;
    pub const CLIENT_CHANGE_SKIN_REQ: u32 = 1390;
    pub const CLIENT_CHANGE_SKIN_ACK: u32 = 1391;
    pub const CLIENT_CHANGE_SKIN_NTF: u32 = 1392;

    // Inventory & Item Operations
    pub const CLIENT_DECOMPOSE_REQ: u32 = 1049;
    pub const CLIENT_DECOMPOSE_ACK: u32 = 1050;
    pub const CLIENT_DECOMPOSE_NTF: u32 = 1051;
    pub const CLIENT_USE_GOODS_REQ: u32 = 1055;
    pub const CLIENT_USE_GOODS_ACK: u32 = 1056;
    pub const CLIENT_USE_GOODS_NTF: u32 = 1057;
    pub const CLIENT_EXPAND_REQ: u32 = 1091;
    pub const CLIENT_EXPAND_ACK: u32 = 1092;
    pub const CLIENT_EXPAND_NTF: u32 = 1093;
    pub const CLIENT_CHANGE_LOCK_REQ: u32 = 1396;
    pub const CLIENT_CHANGE_LOCK_ACK: u32 = 1397;
    pub const CLIENT_CHANGE_LOCK_NTF: u32 = 1398;

    // Driver Intimacy & Resonance Gear
    pub const CLIENT_EQUIP_UP_REQ: u32 = 1064;
    pub const CLIENT_EQUIP_UP_ACK: u32 = 1065;
    pub const CLIENT_EQUIP_UP_NTF: u32 = 1066;
    pub const CLIENT_HERO_CHANGE_ARMOR_REQ: u32 = 1085;
    pub const CLIENT_HERO_CHANGE_ARMOR_ACK: u32 = 1086;
    pub const CLIENT_HERO_CHANGE_ARMOR_NTF: u32 = 1087;
    pub const CLIENT_HERO_FAVOR_UP_REQ: u32 = 1354;
    pub const CLIENT_HERO_FAVOR_UP_ACK: u32 = 1355;
    pub const CLIENT_HERO_FAVOR_UP_NTF: u32 = 1356;

    // Stamina & Buy Counters
    pub const CLIENT_BUY_VIGOR_REQ: u32 = 1187;
    pub const CLIENT_BUY_VIGOR_ACK: u32 = 1188;
    pub const CLIENT_BUY_VIGOR_NTF: u32 = 1189;
    pub const CLIENT_GET_BUY_NUMBER_REQ: u32 = 1196;
    pub const CLIENT_GET_BUY_NUMBER_ACK: u32 = 1197;
    pub const CLIENT_GET_BUY_NUMBER_NTF: u32 = 1198;

    // One-Key Task Claim & CDKey
    pub const CLIENT_CDKEY_REQ: u32 = 1339;
    pub const CLIENT_CDKEY_ACK: u32 = 1340;
    pub const CLIENT_CDKEY_NTF: u32 = 1341;
    pub const CLIENT_TASK_REWARD_ONE_KEY_REQ: u32 = 2001;
    pub const CLIENT_TASK_REWARD_ONE_KEY_ACK: u32 = 2002;

    // Ark / Dormitory
    pub const CLIENT_GET_HOME_DATA_REQ: u32 = 1199;
    pub const CLIENT_GET_HOME_DATA_ACK: u32 = 1200;
    pub const CLIENT_GET_HOME_DATA_NTF: u32 = 1201;
    pub const CLIENT_BUILD_HOME_REQ: u32 = 1202;
    pub const CLIENT_BUILD_HOME_ACK: u32 = 1203;
    pub const CLIENT_BUILD_HOME_NTF: u32 = 1204;
    pub const CLIENT_HOME_REAP_REQ: u32 = 1205;
    pub const CLIENT_HOME_REAP_ACK: u32 = 1206;
    pub const CLIENT_HOME_REAP_NTF: u32 = 1207;
    pub const CLIENT_HOMEBASE_BUILD_REQ: u32 = 1322;
    pub const CLIENT_HOMEBASE_BUILD_ACK: u32 = 1323;
    pub const CLIENT_HOMEBASE_BUILD_NTF: u32 = 1324;
    pub const CLIENT_CHOOSE_HOME_ROLE_REQ: u32 = 1328;
    pub const CLIENT_CHOOSE_HOME_ROLE_ACK: u32 = 1329;
    pub const CLIENT_CHOOSE_HOME_ROLE_NTF: u32 = 1330;
    pub const CLIENT_START_HOME_EXPEDITION_REQ: u32 = 1208;
    pub const CLIENT_START_HOME_EXPEDITION_ACK: u32 = 1209;
    pub const CLIENT_START_HOME_EXPEDITION_NTF: u32 = 1210;
    pub const CLIENT_HOME_MAKE_REQ: u32 = 1211;
    pub const CLIENT_HOME_MAKE_ACK: u32 = 1212;
    pub const CLIENT_HOME_MAKE_NTF: u32 = 1213;
    pub const CLIENT_END_HOME_EXPEDITION_REQ: u32 = 1232;
    pub const CLIENT_END_HOME_EXPEDITION_ACK: u32 = 1233;
    pub const CLIENT_END_HOME_EXPEDITION_NTF: u32 = 1234;
    pub const CLIENT_GET_HOME_EXPEDITION_REQ: u32 = 1235;
    pub const CLIENT_GET_HOME_EXPEDITION_ACK: u32 = 1236;
    pub const CLIENT_GET_HOME_EXPEDITION_NTF: u32 = 1237;
    pub const CLIENT_SKILLMATERIALS_MAKE_REQ: u32 = 1357;
    pub const CLIENT_SKILLMATERIALS_MAKE_ACK: u32 = 1358;
    pub const CLIENT_SKILLMATERIALS_MAKE_NTF: u32 = 1359;
    pub const CLIENT_CANCEL_HOME_EXPEDITION_REQ: u32 = 1399;
    pub const CLIENT_CANCEL_HOME_EXPEDITION_ACK: u32 = 1400;
    pub const CLIENT_CANCEL_HOME_EXPEDITION_NTF: u32 = 1401;

    // Onsen / Bathhouse Mini-game
    pub const CLIENT_GET_GAME_INFO_REQ: u32 = 1223;
    pub const CLIENT_GET_GAME_INFO_ACK: u32 = 1224;
    pub const CLIENT_GET_GAME_INFO_NTF: u32 = 1225;
    pub const CLIENT_REPORT_GAME_INFO_REQ: u32 = 1226;
    pub const CLIENT_REPORT_GAME_INFO_ACK: u32 = 1227;
    pub const CLIENT_REPORT_GAME_INFO_NTF: u32 = 1228;
    pub const CLIENT_ANSWER_GAME_INFO_REQ: u32 = 1229;
    pub const CLIENT_ANSWER_GAME_INFO_ACK: u32 = 1230;
    pub const CLIENT_ANSWER_GAME_INFO_NTF: u32 = 1231;
    pub const CLIENT_GET_N_GAME_INFO_REQ: u32 = 1438;
    pub const CLIENT_GET_N_GAME_INFO_ACK: u32 = 1439;
    pub const CLIENT_GET_N_GAME_INFO_NTF: u32 = 1440;
    pub const CLIENT_N_GAME_PHASE_UP_REQ: u32 = 1441;
    pub const CLIENT_N_GAME_PHASE_UP_ACK: u32 = 1442;
    pub const CLIENT_N_GAME_PHASE_UP_NTF: u32 = 1443;
    pub const CLIENT_N_GAME_FINISH_REQ: u32 = 1444;
    pub const CLIENT_N_GAME_FINISH_ACK: u32 = 1445;
    pub const CLIENT_N_GAME_FINISH_NTF: u32 = 1446;
    pub const CLIENT_GET_N_GAME_REWARD_REQ: u32 = 1447;
    pub const CLIENT_GET_N_GAME_REWARD_ACK: u32 = 1448;
    pub const CLIENT_GET_N_GAME_REWARD_NTF: u32 = 1449;

    // Guild / Club
    pub const CLIENT_GET_CLUB_INFO_REQ: u32 = 1363;
    pub const CLIENT_GET_CLUB_INFO_ACK: u32 = 1364;
    pub const CLIENT_GET_CLUB_INFO_NTF: u32 = 1365;
    pub const CLIENT_CREATE_CLUB_INFO_REQ: u32 = 1366;
    pub const CLIENT_CREATE_CLUB_INFO_ACK: u32 = 1367;
    pub const CLIENT_CREATE_CLUB_INFO_NTF: u32 = 1368;

    // Shop List / Discounts (Skin Shop)
    pub const CLIENT_SHOP_LIST_REQ: u32 = 2007;
    pub const CLIENT_SHOP_LIST_ACK: u32 = 2008;
    pub const CLIENT_SHOP_LIST_NTF: u32 = 2009;
};

// Protobuf wire primitives
pub fn writeVarint(buf: []u8, offset: *usize, value: u64) void {
    var v = value;
    while (v >= 0x80) {
        if (offset.* < buf.len) {
            buf[offset.*] = @as(u8, @truncate(v & 0x7F)) | 0x80;
        }
        offset.* += 1;
        v >>= 7;
    }
    if (offset.* < buf.len) {
        buf[offset.*] = @as(u8, @truncate(v));
    }
    offset.* += 1;
}

pub fn writeTag(buf: []u8, offset: *usize, field_num: u32, wire_type: u3) void {
    writeVarint(buf, offset, (@as(u64, field_num) << 3) | wire_type);
}

pub fn writeRequiredInt32(buf: []u8, offset: *usize, field_num: u32, value: i32) void {
    writeTag(buf, offset, field_num, 0);
    writeVarint(buf, offset, @as(u64, @intCast(@as(u32, @bitCast(value)))));
}

pub fn writeRequiredInt64(buf: []u8, offset: *usize, field_num: u32, value: i64) void {
    writeTag(buf, offset, field_num, 0);
    writeVarint(buf, offset, @as(u64, @bitCast(value)));
}

pub fn writeRequiredUint64(buf: []u8, offset: *usize, field_num: u32, value: u64) void {
    writeTag(buf, offset, field_num, 0);
    writeVarint(buf, offset, value);
}

pub fn writeInt32(buf: []u8, offset: *usize, field_num: u32, value: i32) void {
    if (value == 0) return;
    writeTag(buf, offset, field_num, 0);
    writeVarint(buf, offset, @as(u64, @intCast(@as(u32, @bitCast(value)))));
}

pub fn writeInt64(buf: []u8, offset: *usize, field_num: u32, value: i64) void {
    if (value == 0) return;
    writeTag(buf, offset, field_num, 0);
    writeVarint(buf, offset, @as(u64, @bitCast(value)));
}

pub fn writeString(buf: []u8, offset: *usize, field_num: u32, str: []const u8) void {
    if (str.len == 0) return;
    writeTag(buf, offset, field_num, 2);
    writeVarint(buf, offset, str.len);
    @memcpy(buf[offset.* .. offset.* + str.len], str);
    offset.* += str.len;
}

pub fn writeSubmessage(buf: []u8, offset: *usize, field_num: u32, msg_bytes: []const u8) void {
    writeTag(buf, offset, field_num, 2);
    writeVarint(buf, offset, msg_bytes.len);
    @memcpy(buf[offset.* .. offset.* + msg_bytes.len], msg_bytes);
    offset.* += msg_bytes.len;
}

pub fn readVarint(buf: []const u8, offset: *usize) ?u64 {
    var result: u64 = 0;
    var shift: u6 = 0;
    while (offset.* < buf.len) {
        const byte = buf[offset.*];
        offset.* += 1;
        result |= @as(u64, byte & 0x7F) << shift;
        if ((byte & 0x80) == 0) return result;
        shift += 7;
        if (shift >= 64) return null;
    }
    return null;
}

pub const ClientRecruitREQ = struct {
    recruitID: i32 = 0,
    count: i32 = 1,
    clientRecruitIndex: i32 = 0,
};

pub fn decodeClientRecruitREQ(payload: []const u8) ClientRecruitREQ {
    var req = ClientRecruitREQ{};
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) req.recruitID = val
            else if (field_num == 3) req.count = val
            else if (field_num == 6) req.clientRecruitIndex = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    if (req.count <= 0) req.count = 1;
    return req;
}

pub const ClientTaskPerformREQ = struct {
    taskType: i32 = 0,
    taskID: i32 = 0,
};

pub fn decodeClientTaskPerformREQ(payload: []const u8) ClientTaskPerformREQ {
    var req = ClientTaskPerformREQ{};
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) req.taskType = val
            else if (field_num == 2) req.taskID = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    return req;
}

// Encoders for specific Haze Reverb protobuf messages

pub fn encodeHeartbeatMSG(buf: []u8, rev: []const u8) usize {
    var offset: usize = 0;
    writeString(buf, &offset, 1, rev);
    return offset;
}

pub fn encodeClientVerifyACK(buf: []u8, errNo: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, errNo);
    return offset;
}

pub fn encodeGoodsItem(buf: []u8, goodsType: i32, goodsID: i32, goodsNum: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, goodsType);
    writeRequiredInt32(buf, &offset, 2, goodsID);
    writeRequiredInt32(buf, &offset, 3, goodsNum);
    return offset;
}

pub fn encodeHeroInfo(
    buf: []u8,
    heroID: i32,
    heroLevel: i32,
    heroStar: i32,
    heroAwaken: i32,
    heroSkillLevel: i32,
    heroFavor: i32,
) usize {
    var offset: usize = 0;
    const now = time(null);
    writeRequiredInt32(buf, &offset, 1, heroID);
    writeRequiredInt32(buf, &offset, 2, heroLevel);
    writeRequiredInt32(buf, &offset, 3, 0); // heroExp (REQUIRED)
    writeRequiredInt32(buf, &offset, 4, heroStar);
    writeRequiredInt32(buf, &offset, 5, heroAwaken);
    writeRequiredInt32(buf, &offset, 6, heroSkillLevel);
    writeRequiredInt32(buf, &offset, 7, 0); // heroArmor1 (REQUIRED)
    writeRequiredInt32(buf, &offset, 8, 0); // heroArmor2 (REQUIRED)
    writeRequiredInt64(buf, &offset, 9, now); // heroCTime (REQUIRED)
    writeRequiredInt32(buf, &offset, 10, heroFavor);
    writeRequiredInt32(buf, &offset, 11, heroSkillLevel); // heroCurSkill (REQUIRED)
    writeRequiredInt32(buf, &offset, 12, 0); // heroFlag (REQUIRED)
    writeRequiredInt32(buf, &offset, 13, 0); // heroDefArmor1 (REQUIRED)
    writeRequiredInt32(buf, &offset, 14, 0); // heroDefArmor2 (REQUIRED)
    writeRequiredInt32(buf, &offset, 15, 0); // sEquipOff (REQUIRED)
    return offset;
}

extern "c" fn time(?*i64) i64;

pub fn encodeVigorInfo(buf: []u8, vigorNum: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, vigorNum);
    writeRequiredInt64(buf, &offset, 2, time(null));
    return offset;
}

pub fn encodeTimeInfo(buf: []u8, time_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, time_id);
    writeRequiredInt32(buf, &offset, 2, 999);
    writeString(buf, &offset, 3, "1,2,3,4,5,6,7");
    writeString(buf, &offset, 4, "05-00-00");
    writeString(buf, &offset, 5, "05-00-00");
    writeRequiredInt64(buf, &offset, 6, 0);
    writeRequiredInt64(buf, &offset, 7, 2000000000);
    return offset;
}

pub fn encodeLevelInfo(buf: []u8, level_id: i32, star: i32, count: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, level_id);
    writeRequiredInt32(buf, &offset, 2, star);
    writeRequiredInt32(buf, &offset, 3, count);
    writeRequiredInt32(buf, &offset, 4, 1);
    return offset;
}

pub fn encodeLotteryInfo(buf: []u8, lottery_id: i32, count: i32, up: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, lottery_id);
    writeRequiredInt32(buf, &offset, 2, count);
    writeRequiredInt32(buf, &offset, 3, up);
    return offset;
}

pub fn encodeStatistic(buf: []u8, stat_id: i32, stat_val: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, stat_id);
    writeRequiredInt32(buf, &offset, 2, stat_val);
    return offset;
}

pub fn encodeRecruitHero(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    const hlen = encodeHeroInfo(&hbuf, hero_id, 1, 1, 1, 1, 1);
    writeSubmessage(buf, &offset, 1, hbuf[0..hlen]);
    return offset;
}

pub fn encodeClientRecruitNTF(buf: []u8, recruit_id: i32, count: i32, recruit_index: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    var i: i32 = 0;
    while (i < count) : (i += 1) {
        const raw_idx = @as(usize, @intCast(@mod(@as(i64, recruit_index) * 10 + i, @as(i64, @intCast(data_tables.ALL_HERO_IDS.len)))));
        const hero_id = data_tables.ALL_HERO_IDS[raw_idx];
        const hlen = encodeRecruitHero(&hbuf, hero_id);
        writeSubmessage(buf, &offset, 1, hbuf[0..hlen]);
    }
    writeRequiredInt32(buf, &offset, 3, 0); // up = 0
    writeRequiredInt32(buf, &offset, 4, count); // count
    writeRequiredInt32(buf, &offset, 9, recruit_id); // recruitId
    writeRequiredInt32(buf, &offset, 11, recruit_index + 1); // recruitIndex
    return offset;
}

pub fn encodeClientTaskPerformNTF(buf: []u8, task_type: i32, task_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, task_type);
    writeRequiredInt32(buf, &offset, 2, task_id);
    var gbuf: [64]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 100);
    writeSubmessage(buf, &offset, 3, gbuf[0..glen]);
    writeRequiredInt32(buf, &offset, 8, 100); // userLevel = 100
    writeRequiredInt32(buf, &offset, 9, 99999); // vigor = 99999
    writeRequiredInt32(buf, &offset, 10, 0); // exp = 0
    writeRequiredInt32(buf, &offset, 11, 100); // level = 100
    return offset;
}

pub fn encodeClientLevelInfoNTF(buf: []u8) usize {
    var offset: usize = 0;
    var lbuf: [64]u8 = undefined;
    for (data_tables.ALL_STORY_LEVEL_IDS) |lid| {
        const llen = encodeLevelInfo(&lbuf, lid, 7, 1);
        writeSubmessage(buf, &offset, 1, lbuf[0..llen]);
    }
    return offset;
}

pub fn encodeGodModeVerifyNTF(buf: []u8, user_id: i32, nickname: []const u8) usize {
    var offset: usize = 0;
    const now = time(null);

    // Field 1: errNo (0 = OK) (REQUIRED)
    writeRequiredInt32(buf, &offset, 1, 0);
    // Field 2: userID
    writeRequiredInt32(buf, &offset, 2, user_id);
    // Field 3: nike (nickname)
    writeString(buf, &offset, 3, nickname);
    // Field 4: head (Avatar ID)
    writeRequiredInt32(buf, &offset, 4, 10000);
    // Field 5: alliance
    writeRequiredInt32(buf, &offset, 5, 0);
    // Field 6: level
    writeRequiredInt32(buf, &offset, 6, 100);
    // Field 7: exp
    writeRequiredInt32(buf, &offset, 7, 0);
    // Field 8: status
    writeRequiredInt32(buf, &offset, 8, 0);
    // Field 9: cTime
    writeRequiredInt64(buf, &offset, 9, now);
    // Field 10: uTime
    writeRequiredInt64(buf, &offset, 10, now);
    // Field 11: reNameNum
    writeRequiredInt32(buf, &offset, 11, 0);
    // Field 12: title
    writeString(buf, &offset, 12, "Commander");
    // Field 13: mSign
    writeRequiredInt32(buf, &offset, 13, 30);
    // Field 14: wSign
    writeRequiredInt32(buf, &offset, 14, 7);
    // Field 15: nTime (CRITICAL! Server timestamp for MgrNet.CreateLocalTime)
    writeRequiredInt64(buf, &offset, 15, now);
    // Field 16: menuRoleID
    writeRequiredInt32(buf, &offset, 16, 10000);
    // Field 17: newEmailNum
    writeRequiredInt32(buf, &offset, 17, 0);
    // Field 18: expand
    writeRequiredInt32(buf, &offset, 18, 0);

    // Field 19: VigorInfo (Stamina 900 - below 1000 cap so Ark reaping works)
    var vigor_buf: [64]u8 = undefined;
    const vigor_len = encodeVigorInfo(&vigor_buf, 900);
    writeSubmessage(buf, &offset, 19, vigor_buf[0..vigor_len]);

    // Field 20: repeated LevelInfo levels (All 717 story & dungeon stages 3-starred!)
    var lbuf: [64]u8 = undefined;
    for (data_tables.ALL_STORY_LEVEL_IDS) |lid| {
        const llen = encodeLevelInfo(&lbuf, lid, 7, 1);
        writeSubmessage(buf, &offset, 20, lbuf[0..llen]);
    }

    // Field 21: repeated GoodsItem goods (Unlimited Gems, Gold, Prime Crystals, Tickets)
    var gbuf: [64]u8 = undefined;

    // 100000 = Energy Crystal (Free Gems) 999,999
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 999999);
    writeSubmessage(buf, &offset, 21, gbuf[0..glen]);

    // 100001 = Shield Credits (Gold) 99,999,999
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 99999999);
    writeSubmessage(buf, &offset, 21, gbuf[0..glen]);

    // 100008 = Prime Crystalline (Paid Diamonds) 999,999
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.PRIME_CRYSTAL, 999999);
    writeSubmessage(buf, &offset, 21, gbuf[0..glen]);

    // 110002 = Energy Potion 9,999
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.ENERGY_POTION, 9999);
    writeSubmessage(buf, &offset, 21, gbuf[0..glen]);

    // 110010 = Star Shards 99,999
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.STAR_SHARDS, 99999);
    writeSubmessage(buf, &offset, 21, gbuf[0..glen]);

    // Gacha Tickets 99,999 each
    const tickets = [_]i32{
        data_tables.Currency.TICKET_COMMON,
        data_tables.Currency.TICKET_ELITE,
        data_tables.Currency.TICKET_ACE,
        data_tables.Currency.TICKET_TRANSCENDANT,
        data_tables.Currency.TICKET_FESTIVAL,
        data_tables.Currency.TICKET_NEWYEAR,
        data_tables.Currency.TICKET_HALF_ANNIV,
        data_tables.Currency.TICKET_ELITE_DRILL,
        data_tables.Currency.TICKET_FRESHMAN_DRILL,
        data_tables.Currency.TICKET_LIMITED_1,
        data_tables.Currency.TICKET_LIMITED_2,
    };
    for (tickets) |tid| {
        glen = encodeGoodsItem(&gbuf, 1, tid, 99999);
        writeSubmessage(buf, &offset, 21, gbuf[0..glen]);
    }

    // Dorm Assistant Characters Unlock (goodsType = 4)
    const dorm_assistants = [_]i32{ 90000001, 90000002, 90000003, 90000004 };
    for (dorm_assistants) |asst_id| {
        glen = encodeGoodsItem(&gbuf, 4, asst_id, 1);
        writeSubmessage(buf, &offset, 21, gbuf[0..glen]);
    }

    // Field 22: repeated HeroInfo heros (All 173 characters at Max Level 100 & Star 6)
    var hbuf: [128]u8 = undefined;
    for (data_tables.ALL_HERO_IDS) |hero_id| {
        const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
        writeSubmessage(buf, &offset, 22, hbuf[0..hlen]);
    }

    // Field 23: repeated LotteryInfo lotterys (All 44 recruit pools)
    var lot_buf: [64]u8 = undefined;
    for (data_tables.ALL_LOTTERY_IDS) |pid| {
        const lot_len = encodeLotteryInfo(&lot_buf, pid, 0, 0);
        writeSubmessage(buf, &offset, 23, lot_buf[0..lot_len]);
    }

    // Field 27: dayScore
    writeRequiredInt32(buf, &offset, 27, 100);
    // Field 28: weekScore
    writeRequiredInt32(buf, &offset, 28, 500);
    // Field 29: monthScore
    writeRequiredInt32(buf, &offset, 29, 1000);

    // Field 30: repeated Statistic glory (All 702 achievement stats met!)
    var sbuf: [64]u8 = undefined;
    for (data_tables.ALL_ACHIEVEMENT_STATS) |stat| {
        const slen = encodeStatistic(&sbuf, stat.id, stat.val);
        writeSubmessage(buf, &offset, 30, sbuf[0..slen]);
    }

    // Field 42: headFrame
    writeRequiredInt32(buf, &offset, 42, 1);
    // Field 43: signature
    writeString(buf, &offset, 43, "Zig Server - All Features Unlocked");

    // Field 46: repeated tutorial (All 70 tutorial groups completed!)
    for (data_tables.ALL_TUTORIAL_IDS) |tid| {
        writeRequiredInt32(buf, &offset, 46, tid);
    }

    // Field 53: repeated HomeInfo home (All 7 base facilities)
    const base_buildings = [_]i32{ 100005, 100105, 100205, 100305, 100400, 100500, 100600 };
    var home_buf: [64]u8 = undefined;
    for (base_buildings) |b_id| {
        const hlen = encodeHomeInfo(&home_buf, b_id, now - 86400, now - 86400);
        writeSubmessage(buf, &offset, 53, home_buf[0..hlen]);
    }

    // Field 54: newFriendNum
    writeRequiredInt32(buf, &offset, 54, 0);
    // Field 55: homeRule
    writeRequiredInt32(buf, &offset, 55, 0);

    // Field 59: repeated ActivityItem events (Battlepass activity 20000)
    var abuf: [128]u8 = undefined;
    const alen = encodeActivityItem(&abuf, user_id, 20000, 24);
    writeSubmessage(buf, &offset, 59, abuf[0..alen]);

    // Field 63: supportNum
    writeRequiredInt32(buf, &offset, 63, 0);

    // Field 73: repeated TimeInfo timeInfo (ALL 95 TIME IDs from TimeLocalData)
    var tbuf: [128]u8 = undefined;
    for (data_tables.ALL_TIME_IDS) |time_id| {
        const tlen = encodeTimeInfo(&tbuf, time_id);
        writeSubmessage(buf, &offset, 73, tbuf[0..tlen]);
    }

    // Field 77: weekCopyNum
    writeRequiredInt32(buf, &offset, 77, 0);
    // Field 80: mSignFlag (0 = false = already signed in today, disables full-screen AllMask popup)
    writeRequiredInt32(buf, &offset, 80, 0);

    return offset;
}

// Builds full 16-byte packet: [len: u32][mid: u32][tag: u32][user_id: u32][payload...]
pub fn buildPacket(buf: []u8, mid: u32, tag: u32, user_id: u32, payload: []const u8) usize {
    const payload_len = @as(u32, @intCast(payload.len));
    std.mem.writeInt(u32, buf[0..4], payload_len, .big);
    std.mem.writeInt(u32, buf[4..8], mid, .big);
    std.mem.writeInt(u32, buf[8..12], tag, .big);
    std.mem.writeInt(u32, buf[12..16], user_id, .big);
    @memcpy(buf[16 .. 16 + payload.len], payload);
    return 16 + payload.len;
}

// Encodes PBClient.ClientLoginResult for HTTP /httpLogin
pub fn encodeClientLoginResult(buf: []u8, addrGate: []const u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 0); // errNo = 0
    writeInt32(buf, &offset, 2, 10001); // userID = 10001
    writeString(buf, &offset, 3, "zig_token");
    writeString(buf, &offset, 4, addrGate);
    writeInt32(buf, &offset, 5, 1);
    writeString(buf, &offset, 6, "commander");
    return offset;
}

// Encodes ActivityItem for ClientActivityGetNTF
pub fn encodeActivityItem(buf: []u8, user_id: i32, activity_id: i32, version: i32) usize {
    var offset: usize = 0;
    const now = time(null);
    writeRequiredInt32(buf, &offset, 1, user_id);
    writeRequiredInt32(buf, &offset, 2, activity_id);
    writeRequiredInt32(buf, &offset, 3, version);
    writeRequiredInt32(buf, &offset, 4, 0); // score
    writeRequiredInt64(buf, &offset, 5, now); // uTime
    writeString(buf, &offset, 6, "{}"); // reward (valid JSON empty object)
    return offset;
}

// Encodes PBClient.ClientActivityGetNTF
pub fn encodeClientActivityGetNTF(buf: []u8, user_id: i32) usize {
    var offset: usize = 0;
    var item_buf: [128]u8 = undefined;
    // Activity 20000 (Battlepass, version 24)
    const item_len = encodeActivityItem(&item_buf, user_id, 20000, 24);
    writeSubmessage(buf, &offset, 1, item_buf[0..item_len]);
    return offset;
}

// Encodes PBClient.ClientLimitSignNtf
pub fn encodeClientLimitSignNTF(buf: []u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 0); // errNo = 0
    // Field 3: Goods submessage
    var goods_wrapper_buf: [64]u8 = undefined;
    var wrapper_offset: usize = 0;
    // Inside Goods: field 2: repeated GoodsItem goods (10 Common Tickets: goodsID 110030, num 10)
    var item_buf: [32]u8 = undefined;
    const item_len = encodeGoodsItem(&item_buf, 1, 110030, 10);
    writeSubmessage(&goods_wrapper_buf, &wrapper_offset, 2, item_buf[0..item_len]);

    writeSubmessage(buf, &offset, 3, goods_wrapper_buf[0..wrapper_offset]);
    return offset;
}

// Encodes PBClient.ClientSignInNTF
pub fn encodeClientSignInNTF(buf: []u8) usize {
    var offset: usize = 0;
    // Field 6: type = 1
    writeRequiredInt32(buf, &offset, 6, 1);
    // Field 7: mSign = 30
    writeRequiredInt32(buf, &offset, 7, 30);
    return offset;
}

// Encodes PBClient.ClientTeamSaveNTF (echoes formation to set TeamCorrect = true)
pub fn encodeClientTeamSaveNTF(buf: []u8, req_payload: []const u8) usize {
    if (req_payload.len > 0 and req_payload.len <= buf.len) {
        @memcpy(buf[0..req_payload.len], req_payload);
        return req_payload.len;
    }
    // Fallback: minimal TeamInfo with index = 0
    var team_buf: [64]u8 = undefined;
    var t_offset: usize = 0;
    writeRequiredInt32(&team_buf, &t_offset, 1, 0); // index = 0
    writeString(&team_buf, &t_offset, 2, "Team 1");  // name = "Team 1"

    var offset: usize = 0;
    writeSubmessage(buf, &offset, 1, team_buf[0..t_offset]); // repeated TeamInfo data = 1
    return offset;
}

// Extracts levelID from ClientSetLevelStarExREQ
pub fn decodeLevelIdFromReq(payload: []const u8) i32 {
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag = readVarint(payload, &offset) orelse break;
        const field_num: u32 = @intCast(tag >> 3);
        const wire_type: u3 = @intCast(tag & 0x07);
        if (field_num == 1 and wire_type == 0) {
            const val = readVarint(payload, &offset) orelse break;
            return @as(i32, @bitCast(@as(u32, @truncate(val))));
        } else if (wire_type == 0) {
            _ = readVarint(payload, &offset);
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += @intCast(len);
        } else {
            break;
        }
    }
    return 1;
}

fn encodeProp(buf: []u8, field: i32, val: i64) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, field);
    writeRequiredInt64(buf, &offset, 2, val);
    return offset;
}

fn encodeFighter(buf: []u8, uid: i32, cfg_id: i32, pos: i32, is_left: bool) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, uid);
    writeRequiredInt32(buf, &offset, 2, cfg_id);
    writeRequiredInt32(buf, &offset, 3, pos);
    writeTag(buf, &offset, 4, 0); // bool isLeft
    writeVarint(buf, &offset, if (is_left) 1 else 0);
    writeTag(buf, &offset, 5, 0); // bool Init
    writeVarint(buf, &offset, 1);

    // Props (field 6): Level = 1, CurHp = 10000, MaxHp = 10000, Atk = 1000, Def = 500
    var pbuf: [32]u8 = undefined;
    var plen = encodeProp(&pbuf, 1, 1);
    writeSubmessage(buf, &offset, 6, pbuf[0..plen]);
    plen = encodeProp(&pbuf, 5, 10000);
    writeSubmessage(buf, &offset, 6, pbuf[0..plen]);
    plen = encodeProp(&pbuf, 6, 10000);
    writeSubmessage(buf, &offset, 6, pbuf[0..plen]);
    plen = encodeProp(&pbuf, 8, 1000);
    writeSubmessage(buf, &offset, 6, pbuf[0..plen]);
    plen = encodeProp(&pbuf, 9, 500);
    writeSubmessage(buf, &offset, 6, pbuf[0..plen]);

    return offset;
}

fn encodeStageVideo(buf: []u8, round: i32, turn: i32, atk: i32, def: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, round);
    writeRequiredInt32(buf, &offset, 2, turn);
    writeRequiredInt32(buf, &offset, 3, atk);
    writeRequiredInt32(buf, &offset, 4, def);

    // Action (field 5) with checkPt = 12 (VTurnEnd) and dummy VideoSkill
    var skill_buf: [32]u8 = undefined;
    var s_offset: usize = 0;
    writeRequiredInt32(&skill_buf, &s_offset, 1, 0); // skillID = 0
    writeRequiredInt32(&skill_buf, &s_offset, 2, atk);
    writeRequiredInt32(&skill_buf, &s_offset, 3, def);

    var act_buf: [48]u8 = undefined;
    var a_offset: usize = 0;
    writeRequiredInt32(&act_buf, &a_offset, 1, 12); // checkPt = 12
    writeSubmessage(&act_buf, &a_offset, 2, skill_buf[0..s_offset]);

    writeSubmessage(buf, &offset, 5, act_buf[0..a_offset]);
    return offset;
}

fn encodeRoundAtkOrder(buf: []u8, round: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, round);
    writeRequiredInt32(buf, &offset, 2, 1);
    writeRequiredInt32(buf, &offset, 2, 2);
    return offset;
}

pub fn encodeBattleVideos(buf: []u8, left_win: bool) usize {
    var offset: usize = 0;
    // field 1: bool leftWin
    writeTag(buf, &offset, 1, 0);
    writeVarint(buf, &offset, if (left_win) 1 else 0);

    // field 2: fighters (Player on left, Enemy on right)
    var fbuf: [128]u8 = undefined;
    var flen = encodeFighter(&fbuf, 1, 10001, 0, true);
    writeSubmessage(buf, &offset, 2, fbuf[0..flen]);
    flen = encodeFighter(&fbuf, 2, 90001, 0, false);
    writeSubmessage(buf, &offset, 2, fbuf[0..flen]);

    // field 3: videos (round 99, turn 1: valid table, triggers auto-transition to settlement)
    var vbuf: [128]u8 = undefined;
    const vlen = encodeStageVideo(&vbuf, 99, 1, 1, 2);
    writeSubmessage(buf, &offset, 3, vbuf[0..vlen]);

    // field 4: atkOrders
    var obuf: [32]u8 = undefined;
    const olen = encodeRoundAtkOrder(&obuf, 1);
    writeSubmessage(buf, &offset, 4, obuf[0..olen]);

    return offset;
}

// Encodes PBClient.ClientSetLevelStarExNTF with complete BattleVideos
pub fn encodeClientSetLevelStarExNTF(buf: []u8, level_id: i32) usize {
    var video_buf: [512]u8 = undefined;
    const v_len = encodeBattleVideos(&video_buf, true);

    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, level_id); // levelID = 1
    writeSubmessage(buf, &offset, 2, video_buf[0..v_len]); // video = 2
    return offset;
}

// Encodes PBClient.ClientChooseBattleRewardNTF (3 stars, EXP, items)
pub fn encodeClientChooseBattleRewardNTF(buf: []u8, level_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, level_id); // levelID
    writeRequiredInt32(buf, &offset, 2, 7);        // levelStar = 7 (3 stars)
    writeRequiredInt32(buf, &offset, 3, 100);      // userLevel = 100
    writeRequiredInt32(buf, &offset, 4, 999999);   // userExp

    // VigorInfo (field 5)
    var vigor_buf: [32]u8 = undefined;
    var vig_offset: usize = 0;
    writeRequiredInt32(&vigor_buf, &vig_offset, 1, 99999); // point
    writeRequiredInt32(&vigor_buf, &vig_offset, 2, 200);   // max
    writeRequiredInt32(&vigor_buf, &vig_offset, 3, 0);     // buyCount
    writeRequiredInt32(&vigor_buf, &vig_offset, 4, 0);     // time
    writeSubmessage(buf, &offset, 5, vigor_buf[0..vig_offset]);

    // Rewards (field 7): Gold, Gems, Star Shards
    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 50000);
    writeSubmessage(buf, &offset, 7, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 1000);
    writeSubmessage(buf, &offset, 7, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.STAR_SHARDS, 10);
    writeSubmessage(buf, &offset, 7, gbuf[0..glen]);

    return offset;
}

// Encodes PBClient.ClientSetLevelStarNTF (legacy / event victory)
pub fn encodeClientSetLevelStarNTF(buf: []u8, level_id: i32) usize {
    return encodeClientChooseBattleRewardNTF(buf, level_id);
}

// Encodes PBClient.ClientTowerBattleNTF
pub fn encodeClientTowerBattleNTF(buf: []u8, level_id: i32) usize {
    var video_buf: [512]u8 = undefined;
    const v_len = encodeBattleVideos(&video_buf, true);

    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, level_id);
    writeSubmessage(buf, &offset, 2, video_buf[0..v_len]);
    writeRequiredInt32(buf, &offset, 3, 1); // result = 1 (win)
    return offset;
}

// Encodes PBClient.ClientTowerRewardNTF
pub fn encodeClientTowerRewardNTF(buf: []u8) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 500);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    return offset;
}

// ==================== RANDOM SHOP & MALL ====================

pub fn encodeRandShopItem(buf: []u8, id: i32, count: i32, time_val: i64, goodsID: i32, goodsType: i32, goodsNum: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, id);
    writeRequiredInt32(buf, &offset, 2, count);
    writeRequiredInt64(buf, &offset, 3, time_val);
    writeRequiredInt32(buf, &offset, 4, goodsID);
    writeRequiredInt32(buf, &offset, 5, goodsType);
    writeRequiredInt32(buf, &offset, 6, goodsNum);
    return offset;
}

pub fn encodeMonthCard(buf: []u8, buyTime: i64, remaining: i64) usize {
    var offset: usize = 0;
    writeRequiredInt64(buf, &offset, 1, buyTime);
    writeRequiredInt64(buf, &offset, 2, remaining);
    return offset;
}

pub fn encodeClientGetRandShopItemNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);

    const ShopItemDef = struct {
        id: i32,
        goodsID: i32,
        goodsType: i32,
        goodsNum: i32,
    };

    const items = [_]ShopItemDef{
        .{ .id = 400012, .goodsType = 1, .goodsID = 110030, .goodsNum = 1 },
        .{ .id = 400000, .goodsType = 5, .goodsID = 330280, .goodsNum = 1 },
        .{ .id = 400001, .goodsType = 5, .goodsID = 330281, .goodsNum = 1 },
        .{ .id = 400002, .goodsType = 5, .goodsID = 330282, .goodsNum = 1 },
        .{ .id = 400003, .goodsType = 5, .goodsID = 300050, .goodsNum = 1 },
        .{ .id = 400004, .goodsType = 5, .goodsID = 300051, .goodsNum = 1 },
        .{ .id = 400005, .goodsType = 5, .goodsID = 300052, .goodsNum = 1 },
        .{ .id = 400006, .goodsType = 5, .goodsID = 300060, .goodsNum = 1 },
        .{ .id = 400007, .goodsType = 5, .goodsID = 300061, .goodsNum = 1 },
        .{ .id = 400008, .goodsType = 2, .goodsID = 100001, .goodsNum = 100 },
        .{ .id = 400009, .goodsType = 2, .goodsID = 100000, .goodsNum = 100 },
        .{ .id = 400010, .goodsType = 1, .goodsID = 110020, .goodsNum = 100 },
        .{ .id = 400011, .goodsType = 1, .goodsID = 100001, .goodsNum = 100 },
    };

    var item_buf: [64]u8 = undefined;
    for (items) |it| {
        const ilen = encodeRandShopItem(&item_buf, it.id, 0, now, it.goodsID, it.goodsType, it.goodsNum);
        writeSubmessage(buf, &offset, 1, item_buf[0..ilen]);
    }

    var card_buf: [32]u8 = undefined;
    const clen = encodeMonthCard(&card_buf, now, 86400 * 30);
    writeSubmessage(buf, &offset, 2, card_buf[0..clen]);

    return offset;
}

pub const ClientBuyRandShopItemREQ = struct {
    id: i32 = 400012,
    count: i32 = 1,
};

pub fn decodeClientBuyRandShopItemREQ(payload: []const u8) ClientBuyRandShopItemREQ {
    var res = ClientBuyRandShopItemREQ{};
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) res.id = val
            else if (field_num == 3) res.count = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    return res;
}

pub fn encodeClientBuyRandShopItemNTF(buf: []u8, id: i32, count: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, id);
    writeRequiredInt32(buf, &offset, 2, count);

    // goods (Field 3)
    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.TICKET_COMMON, count);
    writeSubmessage(buf, &offset, 3, gbuf[0..glen]);

    // cost (Field 4)
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 1000 * count);
    writeSubmessage(buf, &offset, 4, gbuf[0..glen]);

    return offset;
}

// ==================== CURRENCY EXCHANGE & SHOP PURCHASE ====================

pub const ClientBuyGoodsREQ = struct {
    goodsID: i32 = 119995,
    buyNum: i32 = 1,
};

pub fn decodeClientBuyGoodsREQ(payload: []const u8) ClientBuyGoodsREQ {
    var res = ClientBuyGoodsREQ{};
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) res.goodsID = val
            else if (field_num == 2) res.buyNum = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    return res;
}

pub fn encodeClientBuyGoodsNTF(buf: []u8, goodsID: i32, buyNum: i32) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;

    if (goodsID == 119995) {
        // Exchange Paid Diamonds (Prime Crystalline 100008) -> Free Diamonds (100000)
        // Cost: Prime Crystal
        var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.PRIME_CRYSTAL, buyNum);
        writeSubmessage(buf, &offset, 1, gbuf[0..glen]);

        // Goods: Free Gems
        glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, buyNum);
        writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    } else {
        // Generic purchase: cost Free Gems, give requested goods
        var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 100 * buyNum);
        writeSubmessage(buf, &offset, 1, gbuf[0..glen]);

        glen = encodeGoodsItem(&gbuf, 1, goodsID, buyNum);
        writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    }

    return offset;
}

// ==================== TASK & ACHIEVEMENT ====================

pub fn encodeTaskInfo(buf: []u8, taskID: i32, taskType: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, taskID);
    writeRequiredInt32(buf, &offset, 2, taskType);
    return offset;
}

pub fn encodeClientTaskGetNTF(buf: []u8) usize {
    var offset: usize = 0;
    var sbuf: [32]u8 = undefined;

    // Field 1: repeated Statistic glory (Achievements)
    var id: i32 = 1000000;
    while (id <= 1000030) : (id += 1) {
        const slen = encodeStatistic(&sbuf, id, 100);
        writeSubmessage(buf, &offset, 1, sbuf[0..slen]);
    }

    // Field 2: repeated Statistic day
    var slen = encodeStatistic(&sbuf, 10000, 10);
    writeSubmessage(buf, &offset, 2, sbuf[0..slen]);

    // Field 3: repeated Statistic week
    slen = encodeStatistic(&sbuf, 20000, 10);
    writeSubmessage(buf, &offset, 3, sbuf[0..slen]);

    // Field 4: repeated Statistic month
    slen = encodeStatistic(&sbuf, 30000, 10);
    writeSubmessage(buf, &offset, 4, sbuf[0..slen]);

    // Field 5: dayScore
    writeRequiredInt32(buf, &offset, 5, 100);
    // Field 6: weekScore
    writeRequiredInt32(buf, &offset, 6, 500);
    // Field 7: monthScore
    writeRequiredInt32(buf, &offset, 7, 1000);

    // Field 8: repeated TaskInfo task
    var tbuf: [32]u8 = undefined;
    const tlen = encodeTaskInfo(&tbuf, 1000000, 1);
    writeSubmessage(buf, &offset, 8, tbuf[0..tlen]);

    return offset;
}

// ==================== MAILBOX SYSTEM ====================

pub fn encodeEmailInfo(
    buf: []u8,
    emailID: u64,
    emailType: i32,
    emailName: []const u8,
    emailHead: []const u8,
    emailTitle: []const u8,
    emailTxt: []const u8,
    goods_id: i32,
    goods_num: i32,
    gTime: i64,
    eTime: i64,
    status: i32,
) usize {
    var offset: usize = 0;
    writeRequiredUint64(buf, &offset, 1, emailID);
    writeRequiredInt32(buf, &offset, 2, emailType);
    writeString(buf, &offset, 3, emailName);
    writeString(buf, &offset, 4, emailHead);
    writeString(buf, &offset, 5, emailTitle);
    writeString(buf, &offset, 6, emailTxt);

    if (goods_id > 0 and goods_num > 0) {
        var gbuf: [32]u8 = undefined;
        const glen = encodeGoodsItem(&gbuf, 1, goods_id, goods_num);
        writeSubmessage(buf, &offset, 7, gbuf[0..glen]);
    }

    writeRequiredInt64(buf, &offset, 8, gTime);
    writeRequiredInt64(buf, &offset, 9, eTime);
    writeRequiredInt32(buf, &offset, 10, status);
    writeString(buf, &offset, 11, "");
    return offset;
}

pub fn encodeClientEmailDataNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);
    const expire = now + 86400 * 365;

    var ebuf: [512]u8 = undefined;
    var elen = encodeEmailInfo(
        &ebuf,
        1,
        1,
        "Operations Team",
        "head_10000",
        "Welcome to Haze Reverb Server!",
        "Welcome Commander! Enjoy 50,000 Diamonds and 50 Recruit Tickets!",
        data_tables.Currency.GEMS,
        50000,
        now,
        expire,
        0,
    );
    writeSubmessage(buf, &offset, 1, ebuf[0..elen]);

    elen = encodeEmailInfo(
        &ebuf,
        2,
        1,
        "HQ Supply Dept",
        "head_10000",
        "Commander Support Package",
        "Here are 100 Ace Recruit Tickets and 10,000,000 Shield Credits for your journey.",
        data_tables.Currency.TICKET_ACE,
        100,
        now,
        expire,
        0,
    );
    writeSubmessage(buf, &offset, 1, ebuf[0..elen]);

    return offset;
}

pub fn decodeEmailID(payload: []const u8) u64 {
    var email_id: u64 = 1;
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = readVarint(payload, &offset) orelse break;
            if (field_num == 1) email_id = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    return email_id;
}

pub fn encodeClientEmailGoodsNTF(buf: []u8, email_id: u64) usize {
    var offset: usize = 0;
    writeRequiredUint64(buf, &offset, 1, email_id);

    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 50000);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.TICKET_ACE, 100);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);

    return offset;
}

pub fn encodeClientEmailGoodsAllNTF(buf: []u8) usize {
    var offset: usize = 0;
    writeRequiredUint64(buf, &offset, 1, 1);
    writeRequiredUint64(buf, &offset, 1, 2);

    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 50000);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.TICKET_ACE, 100);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 10000000);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);

    return offset;
}

pub fn encodeClientEmailLookNTF(buf: []u8, email_id: u64) usize {
    var offset: usize = 0;
    writeRequiredUint64(buf, &offset, 1, email_id);
    return offset;
}

pub fn encodeClientEmailDeleteNTF(buf: []u8, email_id: u64) usize {
    var offset: usize = 0;
    writeRequiredUint64(buf, &offset, 1, email_id);
    return offset;
}

// ==================== HERO PROGRESSION ====================

pub fn decodeHeroIdFromReq(payload: []const u8) i32 {
    var hero_id: i32 = 10000;
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) hero_id = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else {
            break;
        }
    }
    return hero_id;
}

pub fn encodeClientHeroLevelUPNTF(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
    writeSubmessage(buf, &offset, 2, hbuf[0..hlen]);
    return offset;
}

pub fn encodeClientHeroStarNTF(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
    writeSubmessage(buf, &offset, 2, hbuf[0..hlen]);
    return offset;
}

pub fn encodeClientHeroSkillUPNTF(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
    writeSubmessage(buf, &offset, 2, hbuf[0..hlen]);
    return offset;
}

pub fn encodeClientHeroDataNTF(buf: []u8) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    for (data_tables.ALL_HERO_IDS) |hero_id| {
        const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
        writeSubmessage(buf, &offset, 1, hbuf[0..hlen]);
    }
    return offset;
}

// ==================== FRIENDS SYSTEM ====================

pub fn encodeClientGetFriendInfoNTF(buf: []u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 2, 0); // vigor = 0
    writeRequiredInt32(buf, &offset, 3, 0); // clientGold = 0
    writeRequiredInt32(buf, &offset, 4, 0); // gold = 0
    writeRequiredInt32(buf, &offset, 5, 1); // page = 1
    writeRequiredInt32(buf, &offset, 6, 0); // friendCount = 0
    writeRequiredInt32(buf, &offset, 7, 0); // friendApplyCount = 0
    return offset;
}

// ==================== GENERIC DECODERS ====================

pub fn decodeStringField1(payload: []const u8) []const u8 {
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            const ulen = @as(usize, @intCast(len));
            if (offset + ulen <= payload.len) {
                if (field_num == 1) return payload[offset .. offset + ulen];
                offset += ulen;
            } else break;
        } else if (wire_type == 0) {
            _ = readVarint(payload, &offset) orelse break;
        } else break;
    }
    return "";
}

pub fn decodeInt32Field1(payload: []const u8) i32 {
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) return val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else break;
    }
    return 0;
}

// ==================== STAGE SWEEP ====================

pub const ClientSweepLevelStarREQ = struct {
    levelID: i32 = 10101,
    frequency: i32 = 1,
};

pub fn decodeClientSweepLevelStarREQ(payload: []const u8) ClientSweepLevelStarREQ {
    var req = ClientSweepLevelStarREQ{};
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) req.levelID = val;
            if (field_num == 2) req.frequency = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else break;
    }
    return req;
}

pub fn encodeClientSweepLevelStarNTF(buf: []u8, level_id: i32, frequency: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, level_id);
    writeRequiredInt32(buf, &offset, 2, 100); // userLevel = 100
    writeRequiredInt32(buf, &offset, 3, 999999); // userExp

    // Field 4: VigorInfo vigor
    var vbuf: [64]u8 = undefined;
    const vlen = encodeVigorInfo(&vbuf, 9999);
    writeSubmessage(buf, &offset, 4, vbuf[0..vlen]);

    // Field 5: repeated GoodsItem cost
    var gbuf: [32]u8 = undefined;
    const clen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.VIGOR, 10 * frequency);
    writeSubmessage(buf, &offset, 5, gbuf[0..clen]);

    // Field 6: repeated GoodsItem reward
    const gold_len = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 50000 * frequency);
    writeSubmessage(buf, &offset, 6, gbuf[0..gold_len]);
    const exp_len = encodeGoodsItem(&gbuf, 1, data_tables.Currency.HERO_EXP, 20000 * frequency);
    writeSubmessage(buf, &offset, 6, gbuf[0..exp_len]);

    // Field 8: repeated Statistic glory
    var sbuf: [32]u8 = undefined;
    var slen = encodeStatistic(&sbuf, 1000000, 100);
    writeSubmessage(buf, &offset, 8, sbuf[0..slen]);
    // Field 9: repeated Statistic day
    slen = encodeStatistic(&sbuf, 10000, 10);
    writeSubmessage(buf, &offset, 9, sbuf[0..slen]);
    // Field 10: repeated Statistic week
    slen = encodeStatistic(&sbuf, 20000, 10);
    writeSubmessage(buf, &offset, 10, sbuf[0..slen]);
    // Field 11: repeated Statistic month
    slen = encodeStatistic(&sbuf, 30000, 10);
    writeSubmessage(buf, &offset, 11, sbuf[0..slen]);

    // Field 12: weekCopyNum
    writeRequiredInt32(buf, &offset, 12, 0);
    return offset;
}

// ==================== PROFILE & PERSONALIZATION ====================

pub fn encodeStringNTF(buf: []u8, field_num: u32, str: []const u8) usize {
    var offset: usize = 0;
    writeString(buf, &offset, field_num, str);
    return offset;
}

pub fn encodeInt32NTF(buf: []u8, field_num: u32, val: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, field_num, val);
    return offset;
}

pub fn encodeHighLadderBase(buf: []u8, rank: i32, score: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, rank);
    writeRequiredInt32(buf, &offset, 2, score);
    writeRequiredInt32(buf, &offset, 3, 10);
    writeRequiredInt32(buf, &offset, 4, 3000);
    writeRequiredInt32(buf, &offset, 5, 10);
    writeRequiredInt32(buf, &offset, 6, 3000);
    writeRequiredInt32(buf, &offset, 7, 50);
    writeRequiredInt32(buf, &offset, 8, 2);
    writeRequiredInt32(buf, &offset, 9, 30);
    writeRequiredInt32(buf, &offset, 10, 5);
    writeRequiredInt32(buf, &offset, 11, 10);
    writeRequiredInt32(buf, &offset, 12, 1);
    return offset;
}

pub fn encodeClientGetHighLadderBaseNTF(buf: []u8) usize {
    var offset: usize = 0;
    var lbuf: [128]u8 = undefined;
    const llen = encodeHighLadderBase(&lbuf, 1, 3000);
    writeSubmessage(buf, &offset, 1, lbuf[0..llen]); // Field 1: HighLadderBase big
    writeSubmessage(buf, &offset, 2, lbuf[0..llen]); // Field 2: HighLadderBase small
    return offset;
}

pub fn encodeClientFriendSupportGetNTF(buf: []u8, user_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, user_id);
    return offset;
}

// ==================== INVENTORY & ITEMS ====================

pub fn encodeClientUseGoodsNTF(buf: []u8, goods_id: i32, goods_num: i32) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;
    // Field 1: GoodsItem cost
    const clen = encodeGoodsItem(&gbuf, 1, goods_id, goods_num);
    writeSubmessage(buf, &offset, 1, gbuf[0..clen]);

    // Field 2: VigorInfo vigor
    var vbuf: [64]u8 = undefined;
    const vlen = encodeVigorInfo(&vbuf, 9999);
    writeSubmessage(buf, &offset, 2, vbuf[0..vlen]);

    // Field 3: repeated GoodsItem goods
    const rlen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 1000 * goods_num);
    writeSubmessage(buf, &offset, 3, gbuf[0..rlen]);
    return offset;
}

pub fn encodeClientExpandNTF(buf: []u8, expand_slots: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, expand_slots);
    return offset;
}

pub fn encodeClientDecomposeNTF(buf: []u8) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 100000);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]); // Field 2: repeated GoodsItem obtain
    return offset;
}

pub fn encodeClientChangeLockNTF(buf: []u8, status: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 2, status);
    return offset;
}

// ==================== DRIVER INTIMACY & GEAR ====================

pub fn encodeClientHeroFavorUPNTF(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    var hbuf: [128]u8 = undefined;
    const hlen = encodeHeroInfo(&hbuf, hero_id, 100, 6, 1, 10, 10);
    writeSubmessage(buf, &offset, 2, hbuf[0..hlen]); // Field 2: HeroInfo info
    return offset;
}

pub fn encodeClientHeroChangeArmorNTF(buf: []u8, payload: []const u8) usize {
    @memcpy(buf[0..payload.len], payload);
    return payload.len;
}

pub fn encodeClientEquipUPNTF(buf: []u8, equip_id: i32, equip_level: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 2, equip_id);
    writeRequiredInt32(buf, &offset, 3, equip_level);
    return offset;
}

// ==================== STAMINA & BUY COUNTERS ====================

pub fn encodeShopInfo(buf: []u8, shop_id: i32, buy_count: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, shop_id);
    writeRequiredInt32(buf, &offset, 2, buy_count);
    return offset;
}

pub fn encodeClientGetBuyNumberNTF(buf: []u8) usize {
    var offset: usize = 0;
    var sbuf: [32]u8 = undefined;
    const slen = encodeShopInfo(&sbuf, 1, 0);
    writeSubmessage(buf, &offset, 1, sbuf[0..slen]); // buyItem

    const now = time(null);
    writeRequiredInt64(buf, &offset, 7, now);
    writeRequiredInt64(buf, &offset, 8, now + 86400 * 30);
    return offset;
}

pub fn encodeClientBuySpecialNTF(buf: []u8, id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, id);
    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.VIGOR, 120);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    return offset;
}

// ==================== ONE-KEY CLAIM & CDKEY ====================

pub fn encodeClientTaskRewardOneKeyAck(buf: []u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 0); // errNo = 0
    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 500);
    writeSubmessage(buf, &offset, 3, gbuf[0..glen]); // reward
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 200000);
    writeSubmessage(buf, &offset, 3, gbuf[0..glen]);
    writeRequiredInt32(buf, &offset, 5, 100); // dayScore
    writeRequiredInt32(buf, &offset, 6, 500); // weekScore
    writeRequiredInt32(buf, &offset, 7, 1000); // monthScore
    return offset;
}

pub fn encodeClientCDKeyNTF(buf: []u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 1); // email = 1 (reward sent to mailbox)
    return offset;
}

// ==================== ARK / DORMITORY BASE ====================

pub fn encodeHomeInfo(buf: []u8, home_id: i32, c_time: i64, u_time: i64) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, home_id);
    writeRequiredInt64(buf, &offset, 2, c_time);
    writeRequiredInt64(buf, &offset, 3, u_time);
    return offset;
}

pub fn encodeClientGetHomeDataNTF(buf: []u8, role_id: i32) usize {
    var offset: usize = 0;
    const now = time(null);
    const past = now - 86400;

    // All 7 maxed base facilities
    const base_buildings = [_]i32{ 100005, 100105, 100205, 100305, 100400, 100500, 100600 };
    var hbuf: [64]u8 = undefined;
    for (base_buildings) |b_id| {
        const hlen = encodeHomeInfo(&hbuf, b_id, past, past);
        writeSubmessage(buf, &offset, 1, hbuf[0..hlen]);
    }

    const valid_role = if (role_id >= 90000001 and role_id <= 90000004) role_id else 90000001;
    writeRequiredInt32(buf, &offset, 2, valid_role);
    return offset;
}

pub fn encodeClientHomeBaseBuildNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);
    const past = now - 86400;

    const base_buildings = [_]i32{ 100005, 100105, 100205, 100305, 100400, 100500, 100600 };
    var hbuf: [64]u8 = undefined;
    for (base_buildings) |b_id| {
        const hlen = encodeHomeInfo(&hbuf, b_id, past, past);
        writeSubmessage(buf, &offset, 1, hbuf[0..hlen]);
    }
    return offset;
}

pub fn encodeClientHomeBuildNTF(buf: []u8, home_id: i32) usize {
    var offset: usize = 0;
    const now = time(null);

    // Field 2: HomeInfo homeInfo
    var hbuf: [64]u8 = undefined;
    const hlen = encodeHomeInfo(&hbuf, if (home_id > 0) home_id else 100005, now, now);
    writeSubmessage(buf, &offset, 2, hbuf[0..hlen]);
    return offset;
}

pub fn encodeHomeReapItem(buf: []u8, u_time: i64, home_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt64(buf, &offset, 1, u_time);
    writeRequiredInt32(buf, &offset, 2, home_id);
    return offset;
}

pub fn encodeClientHomeReapNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);

    // Field 1: goods
    var gbuf: [32]u8 = undefined;
    var glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GOLD, 100000);
    writeSubmessage(buf, &offset, 1, gbuf[0..glen]);
    // goodsType 4, goodsID 100001 -> handled as stamina in Ark_UI.lua:1762
    glen = encodeGoodsItem(&gbuf, 4, 100001, 60);
    writeSubmessage(buf, &offset, 1, gbuf[0..glen]);
    glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.HERO_EXP, 50000);
    writeSubmessage(buf, &offset, 1, gbuf[0..glen]);

    // Field 2: repeated item homeUP
    const base_buildings = [_]i32{ 100005, 100105, 100205, 100305, 100400, 100500, 100600 };
    var ibuf: [32]u8 = undefined;
    for (base_buildings) |b_id| {
        const ilen = encodeHomeReapItem(&ibuf, now, b_id);
        writeSubmessage(buf, &offset, 2, ibuf[0..ilen]);
    }

    // Field 7: VigorInfo
    var vbuf: [64]u8 = undefined;
    const vlen = encodeVigorInfo(&vbuf, 900);
    writeSubmessage(buf, &offset, 7, vbuf[0..vlen]);
    return offset;
}

pub fn encodeExpeditionInfo(buf: []u8, id: i32, exp_id: i32, hero_ids: []const i32, status: i32, u_time: i64) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, id);
    writeRequiredInt32(buf, &offset, 2, exp_id);
    for (hero_ids) |hid| {
        writeRequiredInt32(buf, &offset, 3, hid);
    }
    writeRequiredInt32(buf, &offset, 4, status);
    writeRequiredInt64(buf, &offset, 5, u_time);
    return offset;
}

pub fn encodeClientGetHomeExpeditionNTF(buf: []u8) usize {
    _ = buf;
    return 0; // Empty expedition list allows UI to open cleanly
}

pub fn encodeClientStartHomeExpeditionNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);

    var ebuf: [64]u8 = undefined;
    const empty_heroes = [_]i32{};
    const elen = encodeExpeditionInfo(&ebuf, 1, 100000, &empty_heroes, 1, now);
    writeSubmessage(buf, &offset, 1, ebuf[0..elen]);
    return offset;
}

pub fn encodeClientEndHomeExpeditionNTF(buf: []u8) usize {
    _ = buf;
    return 0;
}

pub fn encodeClientHomeMakeNTF(buf: []u8, make_id: i32) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, if (make_id > 0) make_id else 100001, 1);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    return offset;
}

pub fn encodeClientSkillMaterialsMakeNTF(buf: []u8) usize {
    var offset: usize = 0;
    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, 100001, 1000);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    return offset;
}

// ==================== ONSEN / BATHHOUSE MINI-GAME ====================

pub fn encodeClientGetGameInfoNTF(buf: []u8, role_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 101); // mapID
    writeRequiredInt32(buf, &offset, 2, 1);   // pos
    writeRequiredInt32(buf, &offset, 3, 0);   // answer
    writeRequiredInt32(buf, &offset, 4, 0);   // count (0 played today = 3 remaining)
    writeRequiredInt32(buf, &offset, 6, 3);   // maxCount
    const valid_role = if (role_id >= 90000001 and role_id <= 90000004) role_id else 90000001;
    writeRequiredInt32(buf, &offset, 7, valid_role); // roleID
    return offset;
}

pub fn encodeClientReportGameInfoNTF(buf: []u8, event_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, event_id);
    writeRequiredInt32(buf, &offset, 2, 1); // pos
    writeRequiredInt32(buf, &offset, 3, 2); // count
    return offset;
}

pub fn encodeClientAnswerGameInfoNTF(buf: []u8, hero_id: i32) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 1); // result = 1
    writeRequiredInt32(buf, &offset, 2, hero_id);
    return offset;
}

pub fn encodeNGame(buf: []u8, role_id: i32, phase: i32, game_ids: []const u8, game_reward: []const u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, role_id);
    writeRequiredInt32(buf, &offset, 2, phase);
    writeString(buf, &offset, 3, game_ids);
    writeString(buf, &offset, 4, game_reward);
    return offset;
}

pub fn encodeClientNGamePhaseUpNTF(buf: []u8, role_id: i32, phase: i32) usize {
    var offset: usize = 0;
    var nbuf: [128]u8 = undefined;
    const nlen = encodeNGame(&nbuf, role_id, phase + 1, "1", "1");
    writeSubmessage(buf, &offset, 1, nbuf[0..nlen]);
    return offset;
}

pub fn encodeClientNGameRewardNTF(buf: []u8, role_id: i32) usize {
    var offset: usize = 0;
    var nbuf: [128]u8 = undefined;
    const nlen = encodeNGame(&nbuf, role_id, 3, "1,2,3", "1,2,3");
    writeSubmessage(buf, &offset, 1, nbuf[0..nlen]);

    var gbuf: [32]u8 = undefined;
    const glen = encodeGoodsItem(&gbuf, 1, data_tables.Currency.GEMS, 100);
    writeSubmessage(buf, &offset, 2, gbuf[0..glen]);
    return offset;
}

pub fn decodeTwoInt32(payload: []const u8) struct { f1: i32, f2: i32 } {
    var f1: i32 = 0;
    var f2: i32 = 0;
    var offset: usize = 0;
    while (offset < payload.len) {
        const tag_wire = readVarint(payload, &offset) orelse break;
        const field_num = @as(u32, @intCast(tag_wire >> 3));
        const wire_type = @as(u3, @truncate(tag_wire & 0x07));
        if (wire_type == 0) {
            const val = @as(i32, @truncate(@as(i64, @bitCast(readVarint(payload, &offset) orelse break))));
            if (field_num == 1) f1 = val;
            if (field_num == 2) f2 = val;
        } else if (wire_type == 2) {
            const len = readVarint(payload, &offset) orelse break;
            offset += len;
        } else break;
    }
    return .{ .f1 = f1, .f2 = f2 };
}

// ==================== GUILD / CLUB ====================

pub fn encodeClientGetClubInfoNTF(buf: []u8) usize {
    _ = buf;
    return 0; // Empty club & recommend list for clean browser
}

pub fn encodeClientCreateClubInfoNTF(buf: []u8, name: []const u8) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, 1001);
    writeString(buf, &offset, 2, name);
    return offset;
}

// ==================== SHOP LIST / SKIN SHOP ====================

pub fn encodeShopUnit(buf: []u8, id: i32, start_time: i64, end_time: i64) usize {
    var offset: usize = 0;
    writeRequiredInt32(buf, &offset, 1, id);
    writeRequiredInt64(buf, &offset, 2, start_time);
    writeRequiredInt64(buf, &offset, 3, end_time);
    writeRequiredInt64(buf, &offset, 4, start_time);
    writeRequiredInt64(buf, &offset, 5, end_time);
    return offset;
}

pub fn encodeClientShopListNTF(buf: []u8) usize {
    var offset: usize = 0;
    const now = time(null);
    const start_time = now - 86400 * 365;
    const end_time = now + 86400 * 3650;

    var ubuf: [64]u8 = undefined;
    for (data_tables.ALL_SKIN_SHOP_IDS) |skin_id| {
        const ulen = encodeShopUnit(&ubuf, skin_id, start_time, end_time);
        writeSubmessage(buf, &offset, 1, ubuf[0..ulen]);
    }
    return offset;
}



