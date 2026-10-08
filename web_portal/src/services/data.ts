import { UserAccount, SupportTicket, RadarMetric, ClinicianGrant } from '../types';

export const ADMIN_KPIS = {
  totalUsers: 1482,
  activeUsers7D: 1120,
  inactiveUsers: 362,
  premiumUsers: 444,
  freemiumUsers: 1038,
  activePercent: 75.6,
  streakPercent: 82.1,
  premiumPercent: 29.9,
};

export const RADAR_DATA: RadarMetric[] = [
  { axis: 'Cardiac Vitals', value: 92, label: '92%' },
  { axis: 'Hydration', value: 85, label: '85%' },
  { axis: 'Mobility & Steps', value: 78, label: '78%' },
  { axis: 'Nutrition', value: 70, label: '70%' },
  { axis: 'Sleep Arch.', value: 64, label: '64%' },
];

export const INITIAL_USERS: UserAccount[] = [
  {
    id: 'usr_001',
    accountIdentifier: 'USR-8921',
    plan: 'premium',
    platform: 'android',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 12).toISOString(), // 12 mins ago
    status: 'active',
    createdAt: '2026-08-14T09:20:00Z',
  },
  {
    id: 'usr_002',
    accountIdentifier: 'USR-3419',
    plan: 'freemium',
    platform: 'android',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 45).toISOString(), // 45 mins ago
    status: 'active',
    createdAt: '2026-09-02T14:15:00Z',
  },
  {
    id: 'usr_003',
    accountIdentifier: 'USR-9022',
    plan: 'premium',
    platform: 'ios',
    appBuild: 'v1.0.34+37',
    lastActive: new Date(Date.now() - 1000 * 60 * 60 * 3).toISOString(), // 3 hours ago
    status: 'active',
    createdAt: '2026-07-28T18:40:00Z',
  },
  {
    id: 'usr_004',
    accountIdentifier: 'USR-1148',
    plan: 'freemium',
    platform: 'android',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 60 * 38).toISOString(), // 1.5 days ago
    status: 'active',
    createdAt: '2026-08-01T11:00:00Z',
  },
  {
    id: 'usr_005',
    accountIdentifier: 'USR-7734',
    plan: 'premium',
    platform: 'ios',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 60 * 24 * 35).toISOString(), // 35 days ago
    status: 'dormant',
    createdAt: '2026-05-19T08:30:00Z',
  },
  {
    id: 'usr_006',
    accountIdentifier: 'USR-6120',
    plan: 'freemium',
    platform: 'android',
    appBuild: 'v1.0.33+36',
    lastActive: new Date(Date.now() - 1000 * 60 * 60 * 24 * 42).toISOString(), // 42 days ago
    status: 'dormant',
    createdAt: '2026-04-10T16:50:00Z',
  },
  {
    id: 'usr_007',
    accountIdentifier: 'USR-5582',
    plan: 'premium',
    platform: 'web',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 5).toISOString(), // 5 mins ago
    status: 'active',
    createdAt: '2026-09-15T12:00:00Z',
  },
  {
    id: 'usr_008',
    accountIdentifier: 'USR-2940',
    plan: 'freemium',
    platform: 'android',
    appBuild: 'v1.0.35+38',
    lastActive: new Date(Date.now() - 1000 * 60 * 180).toISOString(),
    status: 'active',
    createdAt: '2026-08-30T10:11:00Z',
  },
];

export const INITIAL_TICKETS: SupportTicket[] = [
  {
    id: 'TCK-4819',
    userAccount: INITIAL_USERS[0],
    subject: 'Google Fit background sync step count inquiry',
    category: 'Sync & Wearables',
    status: 'open',
    createdAt: '2026-10-08T03:15:00Z',
    updatedAt: '2026-10-08T04:20:00Z',
    messages: [
      {
        id: 'msg-1',
        sender: 'user',
        senderName: 'USR-8921',
        text: 'Hello team, does the app count my steps when it is swiped away from recent apps on Android 14?',
        timestamp: '03:15 AM',
      },
      {
        id: 'msg-2',
        sender: 'support',
        senderName: 'Support Agent Marcus',
        text: 'Hi there! Yes, Wellnest leverages an Android Foreground Service with hardware step detector sensor listeners. Even when swiped away, your steps continue logging safely!',
        timestamp: '03:45 AM',
      },
      {
        id: 'msg-3',
        sender: 'user',
        senderName: 'USR-8921',
        text: 'Awesome, thank you! Also, can my doctor view my step goals via pair code?',
        timestamp: '04:20 AM',
      },
    ],
  },
  {
    id: 'TCK-3210',
    userAccount: INITIAL_USERS[1],
    subject: 'Biometric fingerprint unlock prompt frequency',
    category: 'Security & Biometrics',
    status: 'in_progress',
    createdAt: '2026-10-08T01:30:00Z',
    updatedAt: '2026-10-08T02:10:00Z',
    messages: [
      {
        id: 'msg-10',
        sender: 'user',
        senderName: 'USR-3419',
        text: 'I enabled the 6-digit pin and biometric lock. Will my fingerprint stay stored locally on my device?',
        timestamp: '01:30 AM',
      },
      {
        id: 'msg-11',
        sender: 'support',
        senderName: 'Support Agent Marcus',
        text: 'Hello! Your biometric template is strictly protected within your device hardware keystore / secure enclave and never transmitted to our cloud servers.',
        timestamp: '02:10 AM',
      },
    ],
  },
  {
    id: 'TCK-1904',
    userAccount: INITIAL_USERS[2],
    subject: 'Premium subscription renewal and partner challenge invite',
    category: 'Subscription',
    status: 'resolved',
    createdAt: '2026-10-07T18:00:00Z',
    updatedAt: '2026-10-07T19:30:00Z',
    messages: [
      {
        id: 'msg-20',
        sender: 'user',
        senderName: 'USR-9022',
        text: 'I upgraded to Wellnest Pro. Can I create multiple shared partner goals?',
        timestamp: '06:00 PM',
      },
      {
        id: 'msg-21',
        sender: 'support',
        senderName: 'Support Agent Elena',
        text: 'Yes! Pro members can host unlimited collaborative goals with custom reminder nudges for friends and family.',
        timestamp: '07:30 PM',
      },
    ],
  },
];

export const DEMO_CLINICIAN_GRANT: ClinicianGrant = {
  pairCode: 'DOC-7842',
  patientLegalName: 'Jane Doe',
  secretAnswer: 'Emerald',
  permittedCategories: ['vitals', 'sleep', 'steps', 'hydration'],
  expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 3.5).toISOString(), // 3.5 hours remaining
  telemetry: {
    restingHeartRateBpm: 64,
    hrvMs: 68,
    bloodOxygenPercent: 99,
    sleepDurationHours: 7.8,
    deepSleepPercent: 24,
    dailySteps: 9482,
    waterIntakeMl: 2200,
  },
};
