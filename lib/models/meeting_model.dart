class FormMeetingDetail {
  String userid;
  String meeting_id;
  String wilayah_id;
  String anggota_id;

  FormMeetingDetail({
    required this.userid,
    required this.meeting_id,
    required this.wilayah_id,
    required this.anggota_id
  });

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'meeting_id': meeting_id,
    'wilayah_id': wilayah_id,
    'anggota_id': anggota_id
  };
}

class TempMeetingDispacthModel {
  final List<TempMeetingDispacth> data;

  TempMeetingDispacthModel({required this.data});

  factory TempMeetingDispacthModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<TempMeetingDispacth> data =
        datas.map((i) => TempMeetingDispacth.fromJsson(i)).toList();
    return TempMeetingDispacthModel(data: data);
  }
}

class MeetingModel {
  final List<Meeting> data;

  MeetingModel({required this.data});

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Meeting> data =
        datas.map((i) => Meeting.fromJsson(i)).toList();
    return MeetingModel(data: data);
  }
}

class MeetingDispatchModel {
  final List<MeetingDispacth> data;

  MeetingDispatchModel({required this.data});

  factory MeetingDispatchModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<MeetingDispacth> data =
        datas.map((i) => MeetingDispacth.fromJsson(i)).toList();
    return MeetingDispatchModel(data: data);
  }
}

class TempMeetingDispacth {
  String? id;
  String? anggota;
  String? nama_wilayah;
  String? totanggota;

  TempMeetingDispacth({
    this.id,
    this.anggota,
    this.nama_wilayah,
    this.totanggota,
  });

  factory TempMeetingDispacth.fromJsson(Map<String, dynamic> json) {
    return TempMeetingDispacth(
      id: json['id'],
      anggota: json['anggota'],
      nama_wilayah: json['nama_wilayah'],
      totanggota: json['totanggota'],
    );
  }
}

class Meeting {
  String? id;
  String? creator_userid;
  String? creator;
  String? wilayah;
  String? tgl_meeting;
  String? jam_meeting;
  String? topik;
  String? lokasi;
  String? participant;
  String? status;
  String? is_hadir;
  String? notulensi;
  String? file_meeting;
  String? is_iuran;
  String? nominal_iuran;

  Meeting({
    this.id,
    this.creator_userid,
    this.creator,
    this.wilayah,
    this.tgl_meeting,
    this.jam_meeting,
    this.topik,
    this.lokasi,
    this.participant,
    this.status,
    this.is_hadir,
    this.notulensi,
    this.file_meeting,
    this.is_iuran,
    this.nominal_iuran,
  });

  factory Meeting.fromJsson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      creator_userid: json['creator_userid'],
      creator: json['creator'],
      wilayah: json['wilayah'],
      tgl_meeting: json['tgl_meeting'],
      jam_meeting: json['jam_meeting'],
      topik: json['topik'],
      lokasi: json['lokasi'],
      participant: json['participant'],
      status: json['status'],
      is_hadir: json['is_hadir'],
      notulensi: json['notulensi'],
      file_meeting: json['file_meeting'],
      is_iuran: json['is_iuran'],
      nominal_iuran: json['nominal_iuran'],
    );
  }
}

class MeetingDispacth {
  String? id;
  String? anggota;
  String? nama_wilayah;
  String? totanggota;
  String? is_hadir;
  String? is_creator;

  MeetingDispacth({
    this.id,
    this.anggota,
    this.nama_wilayah,
    this.totanggota,
    this.is_hadir,
    this.is_creator,
  });

  factory MeetingDispacth.fromJsson(Map<String, dynamic> json) {
    return MeetingDispacth(
      id: json['id'],
      anggota: json['anggota'],
      nama_wilayah: json['nama_wilayah'],
      totanggota: json['totanggota'],
      is_hadir: json['is_hadir'],
      is_creator: json['is_creator'],
    );
  }
}