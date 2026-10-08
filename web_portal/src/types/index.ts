export type PlanTier = 'freemium' | 'premium';

export interface UserAccount {
  id: string;
  accountIdentifier: string; // USR-XXXX
  plan: PlanTier;
  platform: 'android' | 'ios' | 'web';
  appBuild: string;
  lastActive: string; // ISO 8601
  status: 'active' | 'dormant';
  createdAt: string;
}

export type TicketStatus = 'open' | 'in_progress' | 'resolved';

export interface ChatMessage {
  id: string;
  sender: 'user' | 'support';
  senderName: string;
  text: string;
  timestamp: string;
}

export interface SupportTicket {
  id: string;
  userAccount: UserAccount;
  subject: string;
  category: 'Subscription' | 'Sync & Wearables' | 'Security & Biometrics' | 'General';
  status: TicketStatus;
  createdAt: string;
  updatedAt: string;
  messages: ChatMessage[];
}

export interface RadarMetric {
  axis: string;
  value: number; // 0 to 100
  label: string;
}

export interface ClinicianGrant {
  pairCode: string;
  patientLegalName: string;
  secretAnswer: string;
  permittedCategories: ('vitals' | 'sleep' | 'steps' | 'hydration')[];
  expiresAt: string;
  telemetry: {
    restingHeartRateBpm: number;
    hrvMs: number;
    bloodOxygenPercent: number;
    sleepDurationHours: number;
    deepSleepPercent: number;
    dailySteps: number;
    waterIntakeMl: number;
  };
}

export interface ScreenshotAlert {
  id: string;
  timestamp: string;
  trigger: string;
  section: string;
}
