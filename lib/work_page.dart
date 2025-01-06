import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class JobVacancy {
  final String title;
  final String company;
  final String source;
  final String link;

  const JobVacancy({
    required this.title,
    required this.company,
    required this.source,
    required this.link,
  });

  factory JobVacancy.fromJson(Map<String, dynamic> json, String source) {
    switch (source) {
      case 'RemoteOK':
        return JobVacancy(
          title: json['position'] ?? 'Unknown Position',
          company: json['company'] ?? 'Unknown Company',
          source: 'RemoteOK',
          link: json['url'] ?? '',
        );
      case 'GitHub':
        return JobVacancy(
          title: json['title'] ?? 'Unknown Job',
          company: json['company'] ?? 'Unknown Company',
          source: 'GitHub Jobs',
          link: json['url'] ?? '',
        );
      case 'WeWorkRemotely':
        return JobVacancy(
          title: json['job_title'] ?? 'Unknown Job',
          company: json['company'] ?? 'Unknown Company',
          source: 'We Work Remotely',
          link: json['url'] ?? '',
        );
      // Добавьте другие источники здесь
      default:
        return JobVacancy(
          title: 'Unknown Job',
          company: 'Unknown Company',
          source: source,
          link: '',
        );
    }
  }
}

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  _WorkPageState createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  List<JobVacancy> jobs = [];
  bool isLoading = true;
  String? errorMessage;

  // Список источников работы
  final List<String> jobSources = [
    'RemoteOK',
    'GitHub',
    'WeWorkRemotely',
    'Stack Overflow Jobs',
    'LinkedIn',
    'Indeed',
    'Glassdoor',
    'Monster',
    'CareerBuilder',
    'AngelList',
    'Dice',
    'ZipRecruiter',
    'Hired',
    'TopTal',
    'Upwork',
    'Freelancer',
    'PeoplePerHour',
    'FlexJobs',
    'Remote.co',
    'JustRemote',
    'Remotive',
    'DevOpssJobs',
    'StartupJobs',
    'TechJobs',
    'NoDesk',
    'WorkingNomads',
    'RemoteFriendly',
    'JrDevJobs',
    'Honeypot',
    'X-Team'
  ];

  @override
  void initState() {
    super.initState();
    fetchJobsFromMultipleSources();
  }

  Future<void> fetchJobsFromMultipleSources() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      jobs = [];
    });

    for (var source in jobSources) {
      try {
        await _fetchJobsFromSource(source);
      } catch (e) {
        print('Ошибка при загрузке из $source: ${e.toString()}');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchJobsFromSource(String source) async {
    switch (source) {
      case 'RemoteOK':
        final response = await http.get(Uri.parse('https://remoteok.com/api'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final remoteOkJobs = data
              .skip(1)
              .map((job) => JobVacancy.fromJson(job, source))
              .toList();
          jobs.addAll(remoteOkJobs);
        }
        break;
      // Добавьте логику для других источников
      // Примечание: Реальная реализация потребует индивидуальных API для каждого источника
      default:
        // Имитация данных для демонстрации
        jobs.add(JobVacancy(
          title: 'Sample Job from $source',
          company: 'Sample Company',
          source: source,
          link: 'https://Stack Overflow Jobs.com',
        ));
    }
  }

  Future<void> _openJobLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Не удалось открыть ссылку: $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacations (${jobs.length} amaunrt)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchJobsFromMultipleSources,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text('${job.company} (${job.source})'),
                        trailing: const Icon(Icons.open_in_browser),
                        onTap: () => _openJobLink(job.link),
                      ),
                    );
                  },
                ),
    );
  }
}
