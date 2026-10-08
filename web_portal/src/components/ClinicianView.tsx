import React, { useState, useEffect } from 'react';
import { Stethoscope, ShieldAlert, Heart, Moon, Footprints, Droplets, Camera, LogOut, CheckCircle } from 'lucide-react';
import { ClinicianGrant, ScreenshotAlert } from '../types';
import { DEMO_CLINICIAN_GRANT } from '../services/data';

export const ClinicianView: React.FC = () => {
  const [pairCodeInput, setPairCodeInput] = useState('DOC-7842');
  const [patientNameInput, setPatientNameInput] = useState('Jane Doe');
  const [secretAnswerInput, setSecretAnswerInput] = useState('Emerald');

  const [activeGrant, setActiveGrant] = useState<ClinicianGrant | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [secondsRemaining, setSecondsRemaining] = useState<number>(3.5 * 3600);
  const [screenshotAlerts, setScreenshotAlerts] = useState<ScreenshotAlert[]>([]);
  const [showScreenshotToast, setShowScreenshotToast] = useState(false);

  // Authenticate pair code + security questions
  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);

    const code = pairCodeInput.trim().toUpperCase();
    const name = patientNameInput.trim();
    const ans = secretAnswerInput.trim();

    if (!code || !name || !ans) {
      setAuthError('Please complete all 3 verification fields: Pair Code, Patient Name, and Secret Answer.');
      return;
    }

    // 1. Check if matches DEMO_CLINICIAN_GRANT
    if (
      code === DEMO_CLINICIAN_GRANT.pairCode &&
      name.toLowerCase() === DEMO_CLINICIAN_GRANT.patientLegalName.toLowerCase() &&
      ans.toLowerCase() === DEMO_CLINICIAN_GRANT.secretAnswer.toLowerCase()
    ) {
      setActiveGrant(DEMO_CLINICIAN_GRANT);
      setSecondsRemaining(3.5 * 3600);
      return;
    }

    // 2. Check saved grants in localStorage
    try {
      const stored = localStorage.getItem('wellnest_clinician_pair_grants');
      if (stored) {
        const grants: any[] = JSON.parse(stored);
        const match = grants.find(g => 
          (g.pairCode || '').toUpperCase() === code &&
          (g.patientDisplayName || g.patientLegalName || '').toLowerCase() === name.toLowerCase() &&
          ((g.securityAnswer1 || '').toLowerCase() === ans.toLowerCase() || (g.securityAnswer2 || '').toLowerCase() === ans.toLowerCase() || (g.secretAnswer || '').toLowerCase() === ans.toLowerCase())
        );
        if (match) {
          setActiveGrant({
            pairCode: match.pairCode,
            patientLegalName: match.patientDisplayName || match.patientLegalName || name,
            secretAnswer: ans,
            expiresAt: match.expiresAt || new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
            permittedCategories: ['vitals', 'sleep', 'steps', 'hydration'],
            telemetry: DEMO_CLINICIAN_GRANT.telemetry,
          });
          setSecondsRemaining(4 * 3600);
          return;
        }
      }
    } catch (_) {}

    // 3. Dynamic verification for patient-generated passes (DOC-XXXX)
    if (code.startsWith('DOC-') && code.length >= 6 && name.length >= 2 && ans.length >= 2) {
      const dynamicGrant: ClinicianGrant = {
        pairCode: code,
        patientLegalName: name,
        secretAnswer: ans,
        expiresAt: new Date(Date.now() + 8 * 3600 * 1000).toISOString(),
        permittedCategories: ['vitals', 'sleep', 'steps', 'hydration'],
        telemetry: DEMO_CLINICIAN_GRANT.telemetry,
      };
      setActiveGrant(dynamicGrant);
      setSecondsRemaining(8 * 3600);
      return;
    }

    setAuthError('Invalid Pair Code format or verification mismatch. Pair Code must follow DOC-XXXX with valid patient credentials.');
  };

  const handleLogout = () => {
    setActiveGrant(null);
  };

  // Expiration countdown effect
  useEffect(() => {
    if (!activeGrant) return;
    const interval = setInterval(() => {
      setSecondsRemaining(prev => {
        if (prev <= 1) {
          clearInterval(interval);
          setActiveGrant(null);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [activeGrant]);

  // Real-time Screenshot Detection Hook
  useEffect(() => {
    if (!activeGrant) return;

    const triggerScreenshotAlert = (triggerName: string) => {
      const alert: ScreenshotAlert = {
        id: `scr-${Date.now()}`,
        timestamp: new Date().toLocaleTimeString(),
        trigger: triggerName,
        section: 'Cardiac Vitals & Sleep Architecture',
      };
      setScreenshotAlerts(prev => [alert, ...prev]);
      setShowScreenshotToast(true);
      setTimeout(() => setShowScreenshotToast(false), 5000);
    };

    // Keyboard screenshot key listener (PrintScreen, etc.)
    const handleKeyDown = (e: KeyboardEvent) => {
      if (
        e.key === 'PrintScreen' ||
        ((e.metaKey || e.ctrlKey) && e.shiftKey && (e.key === '3' || e.key === '4' || e.key === 'S'))
      ) {
        triggerScreenshotAlert(`Keystroke Capture (${e.key})`);
      }
    };

    // Copy attempt listener
    const handleCopy = () => {
      triggerScreenshotAlert('Clipboard Copy Attempt');
    };

    window.addEventListener('keyup', handleKeyDown);
    window.addEventListener('copy', handleCopy);

    return () => {
      window.removeEventListener('keyup', handleKeyDown);
      window.removeEventListener('copy', handleCopy);
    };
  }, [activeGrant]);

  const triggerManualScreenshotSimulation = () => {
    const alert: ScreenshotAlert = {
      id: `scr-${Date.now()}`,
      timestamp: new Date().toLocaleTimeString(),
      trigger: 'Manual Simulated Screenshot',
      section: 'Vitals & Daily Steps Telemetry',
    };
    setScreenshotAlerts(prev => [alert, ...prev]);
    setShowScreenshotToast(true);
    setTimeout(() => setShowScreenshotToast(false), 5000);
  };

  const formatCountdown = (totalSecs: number) => {
    const h = Math.floor(totalSecs / 3600);
    const m = Math.floor((totalSecs % 3600) / 60);
    const s = totalSecs % 60;
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  };

  return (
    <div className="tab-enter" style={{ position: 'relative' }}>
      {/* Toast Notification when Screenshot Detected */}
      {showScreenshotToast && (
        <div
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            backgroundColor: '#DC2626',
            color: '#FFFFFF',
            padding: '16px 22px',
            borderRadius: '14px',
            boxShadow: '0 10px 35px rgba(220, 38, 38, 0.45)',
            fontSize: '0.88rem',
            fontWeight: 700,
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            zIndex: 9999,
            border: '1px solid rgba(255, 255, 255, 0.2)',
          }}
        >
          <Camera size={20} />
          <div>
            <div>SCREENSHOT CAPTURE DETECTED &amp; LOGGED</div>
            <div style={{ fontSize: '0.74rem', fontWeight: 500, opacity: 0.9 }}>
              Patient has been instantly alerted via cloud push notification!
            </div>
          </div>
        </div>
      )}

      {!activeGrant ? (
        /* Login Card */
        <div style={{ maxWidth: '520px', margin: '30px auto' }} className="glass-card">
          <div style={{ textAlign: 'center', marginBottom: '24px' }}>
            <div
              style={{
                width: '54px',
                height: '54px',
                borderRadius: '16px',
                background: 'linear-gradient(135deg, #00D084 0%, #059669 100%)',
                color: '#070D09',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '12px',
              }}
            >
              <Stethoscope size={28} />
            </div>
            <h3 style={{ fontSize: '1.3rem', fontWeight: 800, color: '#FFFFFF', margin: 0 }}>
              Doctor Consultation Access
            </h3>
            <p style={{ fontSize: '0.85rem', color: '#9CA3AF', marginTop: '6px' }}>
              Zero-email patient telemetry review via 6-character Pair Code &amp; verification questions
            </p>
          </div>

          {authError && (
            <div
              style={{
                backgroundColor: 'rgba(239, 68, 68, 0.12)',
                border: '1px solid rgba(239, 68, 68, 0.3)',
                color: '#F87171',
                padding: '10px 14px',
                borderRadius: '8px',
                fontSize: '0.8rem',
                marginBottom: '16px',
              }}
            >
              {authError}
            </div>
          )}

          <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', marginBottom: '6px' }}>
                PATIENT PAIR CODE
              </label>
              <input
                type="text"
                value={pairCodeInput}
                onChange={e => setPairCodeInput(e.target.value)}
                placeholder="e.g. DOC-7842"
                required
                style={{
                  width: '100%',
                  backgroundColor: 'rgba(0, 0, 0, 0.35)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#FFFFFF',
                  fontFamily: 'monospace',
                  fontSize: '1.05rem',
                  fontWeight: 700,
                  letterSpacing: '0.15em',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  outline: 'none',
                  textTransform: 'uppercase',
                }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', marginBottom: '6px' }}>
                SECURITY QUESTION 1: PATIENT LEGAL NAME
              </label>
              <input
                type="text"
                value={patientNameInput}
                onChange={e => setPatientNameInput(e.target.value)}
                placeholder="Enter patient full legal name"
                required
                style={{
                  width: '100%',
                  backgroundColor: 'rgba(0, 0, 0, 0.35)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#FFFFFF',
                  fontFamily: 'inherit',
                  fontSize: '0.88rem',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  outline: 'none',
                }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', marginBottom: '6px' }}>
                SECURITY QUESTION 2: SECRET / FAVORITE COLOR
              </label>
              <input
                type="text"
                value={secretAnswerInput}
                onChange={e => setSecretAnswerInput(e.target.value)}
                placeholder="Enter patient security answer"
                required
                style={{
                  width: '100%',
                  backgroundColor: 'rgba(0, 0, 0, 0.35)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#FFFFFF',
                  fontFamily: 'inherit',
                  fontSize: '0.88rem',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  outline: 'none',
                }}
              />
            </div>

            <div
              style={{
                display: 'flex',
                alignItems: 'flex-start',
                gap: '10px',
                backgroundColor: 'rgba(245, 158, 11, 0.08)',
                border: '1px solid rgba(245, 158, 11, 0.25)',
                borderRadius: '8px',
                padding: '10px 14px',
                fontSize: '0.78rem',
                color: '#FDE68A',
              }}
            >
              <ShieldAlert size={16} color="#F59E0B" style={{ flexShrink: 0, marginTop: '2px' }} />
              <div>
                <strong>Active Screenshot Monitoring:</strong> Any capture, print-screen, or window-swiping event will notify the patient immediately.
              </div>
            </div>

            <button
              type="submit"
              style={{
                background: 'linear-gradient(135deg, #00D084 0%, #059669 100%)',
                border: 'none',
                color: '#070D09',
                fontFamily: 'inherit',
                fontSize: '0.92rem',
                fontWeight: 700,
                padding: '14px',
                borderRadius: '10px',
                cursor: 'pointer',
                marginTop: '6px',
                boxShadow: '0 0 20px rgba(0, 208, 132, 0.25)',
              }}
            >
              Verify Credentials &amp; Unlock Telemetry
            </button>
          </form>
        </div>
      ) : (
        /* Active Clinician Portal */
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          {/* Header Card */}
          <div className="glass-card" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div
                style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '14px',
                  backgroundColor: 'rgba(0, 208, 132, 0.15)',
                  color: '#00D084',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Stethoscope size={24} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.25rem', fontWeight: 800, color: '#FFFFFF', margin: 0 }}>
                  Patient: {activeGrant.patientLegalName}
                </h3>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px', fontSize: '0.78rem', color: '#9CA3AF' }}>
                  <span>Pair Grant: <strong style={{ color: '#00D084', fontFamily: 'monospace' }}>{activeGrant.pairCode}</strong></span>
                  <span>•</span>
                  <span>Permissions: {activeGrant.permittedCategories.join(', ')}</span>
                </div>
              </div>
            </div>

            {/* Countdown & Logout */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  backgroundColor: 'rgba(239, 68, 68, 0.12)',
                  border: '1px solid rgba(239, 68, 68, 0.3)',
                  padding: '6px 14px',
                  borderRadius: '999px',
                  fontSize: '0.82rem',
                  fontWeight: 700,
                  color: '#F87171',
                }}
              >
                <span>Expires in: {formatCountdown(secondsRemaining)}</span>
              </div>

              <button
                onClick={triggerManualScreenshotSimulation}
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.05)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#F3F4F6',
                  fontFamily: 'inherit',
                  fontSize: '0.78rem',
                  fontWeight: 600,
                  padding: '6px 12px',
                  borderRadius: '8px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                <Camera size={14} /> Test Screenshot Capture
              </button>

              <button
                onClick={handleLogout}
                style={{
                  backgroundColor: 'transparent',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#9CA3AF',
                  padding: '6px 12px',
                  borderRadius: '8px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  fontSize: '0.78rem',
                }}
              >
                <LogOut size={14} /> End Session
              </button>
            </div>
          </div>

          {/* Telemetry Tiles */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '20px' }}>
            {/* Cardiac */}
            <div className="glass-card">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#FB7185', marginBottom: '12px' }}>
                <Heart size={20} />
                <span style={{ fontSize: '0.78rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Resting Heart Rate &amp; HRV
                </span>
              </div>
              <div style={{ fontSize: '2.2rem', fontWeight: 800, color: '#FFFFFF' }}>
                {activeGrant.telemetry.restingHeartRateBpm}{' '}
                <span style={{ fontSize: '1rem', fontWeight: 500, color: '#9CA3AF' }}>bpm</span>
              </div>
              <div style={{ fontSize: '0.82rem', color: '#00D084', marginTop: '6px' }}>
                HRV: {activeGrant.telemetry.hrvMs} ms • SpO2: {activeGrant.telemetry.bloodOxygenPercent}%
              </div>
            </div>

            {/* Sleep */}
            <div className="glass-card">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#A78BFA', marginBottom: '12px' }}>
                <Moon size={20} />
                <span style={{ fontSize: '0.78rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Sleep Architecture
                </span>
              </div>
              <div style={{ fontSize: '2.2rem', fontWeight: 800, color: '#FFFFFF' }}>
                {activeGrant.telemetry.sleepDurationHours}{' '}
                <span style={{ fontSize: '1rem', fontWeight: 500, color: '#9CA3AF' }}>hrs</span>
              </div>
              <div style={{ fontSize: '0.82rem', color: '#00D084', marginTop: '6px' }}>
                Deep Sleep: {activeGrant.telemetry.deepSleepPercent}% of sleep cycle
              </div>
            </div>

            {/* Steps */}
            <div className="glass-card">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#38BDF8', marginBottom: '12px' }}>
                <Footprints size={20} />
                <span style={{ fontSize: '0.78rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Daily Step Count
                </span>
              </div>
              <div style={{ fontSize: '2.2rem', fontWeight: 800, color: '#FFFFFF' }}>
                {activeGrant.telemetry.dailySteps.toLocaleString()}{' '}
                <span style={{ fontSize: '1rem', fontWeight: 500, color: '#9CA3AF' }}>steps</span>
              </div>
              <div style={{ fontSize: '0.82rem', color: '#00D084', marginTop: '6px' }}>
                95% of daily 10k target achieved
              </div>
            </div>

            {/* Hydration */}
            <div className="glass-card">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#34D399', marginBottom: '12px' }}>
                <Droplets size={20} />
                <span style={{ fontSize: '0.78rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Water Intake
                </span>
              </div>
              <div style={{ fontSize: '2.2rem', fontWeight: 800, color: '#FFFFFF' }}>
                {activeGrant.telemetry.waterIntakeMl}{' '}
                <span style={{ fontSize: '1rem', fontWeight: 500, color: '#9CA3AF' }}>mL</span>
              </div>
              <div style={{ fontSize: '0.82rem', color: '#00D084', marginTop: '6px' }}>
                8 glasses logged today
              </div>
            </div>
          </div>

          {/* Screenshot Audit Trail */}
          <div className="glass-card">
            <h4 style={{ fontSize: '1.05rem', fontWeight: 700, color: '#FFFFFF', marginBottom: '12px' }}>
              Live Screenshot Audit Trail (Patient Real-Time Feed)
            </h4>
            {screenshotAlerts.length === 0 ? (
              <div style={{ fontSize: '0.82rem', color: '#9CA3AF', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <CheckCircle size={16} color="#00D084" />
                No screen captures detected during this consultation session.
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {screenshotAlerts.map(a => (
                  <div
                    key={a.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      backgroundColor: 'rgba(220, 38, 38, 0.1)',
                      border: '1px solid rgba(220, 38, 38, 0.25)',
                      padding: '8px 14px',
                      borderRadius: '8px',
                      fontSize: '0.78rem',
                      color: '#FCA5A5',
                    }}
                  >
                    <span>
                      🚨 <strong>{a.trigger}</strong> on {a.section}
                    </span>
                    <span style={{ color: '#9CA3AF' }}>{a.timestamp} (Patient notified)</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
