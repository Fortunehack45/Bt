import React, { useState } from 'react';
import { Navbar, ActiveTab } from './components/Navbar';
import { AdminView } from './components/AdminView';
import { SupportView } from './components/SupportView';
import { ClinicianView } from './components/ClinicianView';
import { INITIAL_TICKETS } from './services/data';

export const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<ActiveTab>('admin');
  const openTicketCount = INITIAL_TICKETS.filter(t => t.status === 'open').length;

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Navbar
        activeTab={activeTab}
        onTabChange={setActiveTab}
        openTicketCount={openTicketCount}
      />

      <main style={{ flex: 1, maxWidth: '1440px', width: '100%', margin: '0 auto', padding: '32px 28px' }}>
        {activeTab === 'admin' && <AdminView />}
        {activeTab === 'support' && <SupportView />}
        {activeTab === 'clinician' && <ClinicianView />}
      </main>

      <footer
        style={{
          borderTop: '1px solid rgba(255, 255, 255, 0.06)',
          padding: '20px 36px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: '0.78rem',
          color: '#6B7280',
          flexWrap: 'wrap',
          gap: '12px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span>Wellnest Cloud v1.0.36+39</span>
          <span>•</span>
          <span style={{ color: '#00D084' }}>Vercel Edge Optimized</span>
          <span>•</span>
          <span>Firebase Realtime Data Cloud</span>
        </div>
        <div>
          Strict Zero-Knowledge Health Privacy • HIPAA / GDPR Sensitive Data Isolation
        </div>
      </footer>
    </div>
  );
};

export default App;
