/// Clinical & metabolic intelligence report based on ABO blood group genetics.
class BloodGroupHealthReport {
  final String bloodGroup; // 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'
  final String archetype;
  final String cellularTag;
  final String metabolicTrait;
  final String cardiovascularProfile;
  final String optimalWorkouts;
  final String dietaryFocus;
  final String stressResponse;
  final List<String> clinicalRecommendations;

  const BloodGroupHealthReport({
    required this.bloodGroup,
    required this.archetype,
    required this.cellularTag,
    required this.metabolicTrait,
    required this.cardiovascularProfile,
    required this.optimalWorkouts,
    required this.dietaryFocus,
    required this.stressResponse,
    required this.clinicalRecommendations,
  });

  static BloodGroupHealthReport forGroup(String? group) {
    final clean = (group ?? 'O+').trim().toUpperCase();

    if (clean.startsWith('O')) {
      final isRhNeg = clean.contains('-');
      return BloodGroupHealthReport(
        bloodGroup: clean,
        archetype: 'Hunter-Gatherer Vigor Archetype',
        cellularTag: isRhNeg ? 'Universal Red Blood Cell Donor (O-)' : 'Universal Platelet Recipient (O+)',
        metabolicTrait:
            'Elevated baseline gastric acid and pepsinogen; highly efficient lean protein & lipid assimilation; accelerated basal metabolic turnover.',
        cardiovascularProfile:
            'Lower baseline von Willebrand factor (VWF); statistically reduced incidence of arterial plaque adhesion and venous thromboembolism.',
        optimalWorkouts:
            'High-Intensity Interval Training (HIIT), heavy resistance training, cross-country running, kickboxing, and plyometrics.',
        dietaryFocus:
            'Lean poultry, cold-water wild fish, leafy brassicas (broccoli, spinach), dark berries, kelp, and hydration with marine minerals.',
        stressResponse:
            'Rapid catecholamine surge (adrenaline); requires vigorous physical output to clear cortisol and maintain neurological calm.',
        clinicalRecommendations: const [
          'Engage in 3–4 vigorous aerobic or weight training sessions per week.',
          'Prioritize high-biological-value protein within 45 minutes of training.',
          'Optimize post-exercise hydration with mineralized electrolytes.',
        ],
      );
    }

    if (clean.startsWith('A')) {
      final isRhNeg = clean.contains('-');
      return BloodGroupHealthReport(
        bloodGroup: clean,
        archetype: 'Mindful Cultivator Agrarian Archetype',
        cellularTag: isRhNeg ? 'A- Red Cell Donor' : 'A+ Universal Recipient of Type A & O',
        metabolicTrait:
            'Sensitive digestive tract with lower hydrochloric acid; superior assimilation of complex carbohydrates, plant proteins, and phytonutrients.',
        cardiovascularProfile:
            'Higher resting blood viscosity; proactive endothelial health, daily zone 2 movement, and lipid optimization strongly recommended.',
        optimalWorkouts:
            'Vinyasa & Hatha yoga, dynamic pilates, brisk power walking, swimming, tai chi, and low-impact steady-state cardio.',
        dietaryFocus:
            'Plant-forward Mediterranean diet, sprouted legumes, organic soy/tofu, whole grains, extra virgin olive oil, and antioxidant greens.',
        stressResponse:
            'Naturally higher basal cortisol secretion; benefits deeply from mindful breathwork, calming routines, and regular sleep rhythms.',
        clinicalRecommendations: const [
          'Practice 10–15 minutes of slow resonant breathing or meditation daily.',
          'Maintain an organic, fiber-rich plant-forward dietary foundation.',
          'Avoid chronic sleep debt to regulate nighttime cortisol clearance.',
        ],
      );
    }

    if (clean.startsWith('B')) {
      return BloodGroupHealthReport(
        bloodGroup: clean,
        archetype: 'Nomadic Balanced Adaptability Archetype',
        cellularTag: clean.contains('-') ? 'B- Rare Donor' : 'B+ Standard Rh+',
        metabolicTrait:
            'Strong, resilient digestive system; balanced enzyme profile; exceptional tolerance to cultured dairy, balanced grains, and diverse proteins.',
        cardiovascularProfile:
            'Resilient vascular elasticity; highly responsive to rhythmic aerobic training and consistent circadian rest.',
        optimalWorkouts:
            'Moderate outdoor cycling, hiking, recreational tennis, martial arts balance training, and swimming.',
        dietaryFocus:
            'Diverse whole-food nutrition: lean pasture-raised meats, deep-sea fish, cultured yogurt/kefir, oats, and cruciferous vegetables.',
        stressResponse:
            'Harmonious cortisol-adrenaline axis; thrives with mentally stimulating and socially engaging physical pursuits.',
        clinicalRecommendations: const [
          'Balance cardiovascular output with hand-eye agility and coordination sports.',
          'Incorporate fermented cultured foods for optimal microbiome biodiversity.',
          'Maintain steady, structured meal timings to sustain glycemic equilibrium.',
        ],
      );
    }

    if (clean.startsWith('AB')) {
      return BloodGroupHealthReport(
        bloodGroup: clean,
        archetype: 'Modern Synthesizer Archetype',
        cellularTag: clean.contains('+') ? 'Universal Red Blood Cell Recipient (AB+)' : 'Universal Plasma Donor (AB-)',
        metabolicTrait:
            'Complex multi-antigen profile combining Type A gastric sensitivity with Type B metabolic adaptability; benefits from smaller, frequent meals.',
        cardiovascularProfile:
            'Benefits from proactive cardiovascular monitoring, lipid balance, and antioxidant-rich nitric oxide supporting nutrition.',
        optimalWorkouts:
            'Hybrid conditioning: 2 days of interval tempo work combined with 3 days of restorative yoga or isometric core work.',
        dietaryFocus:
            'Wild seafood, organic tofu, steamed green vegetables, kelp, dark cherries, green tea, and anti-inflammatory turmeric.',
        stressResponse:
            'Sensitive autonomic nervous system; responds exceptionally well to nature immersion, ambient soundscapes, and steady routine.',
        clinicalRecommendations: const [
          'Distribute daily nutrition across smaller, easily digestible nutrient-dense meals.',
          'Integrate antioxidant-rich green tea and bioflavonoids into your hydration routine.',
          'Prioritize joint mobility and restorative movement to regulate sympathetic tone.',
        ],
      );
    }

    // Default / Unknown
    return const BloodGroupHealthReport(
      bloodGroup: 'Unknown',
      archetype: 'Universal Clinical Baseline',
      cellularTag: 'General Biometric Profile',
      metabolicTrait: 'Standard metabolic calibration based on Mifflin-St Jeor formula and resting heart rate.',
      cardiovascularProfile: 'Standard physiological cardiovascular metrics calibrated to biological age and weight.',
      optimalWorkouts: 'Balanced mix of 150 minutes of moderate aerobic cardio and 2 resistance sessions weekly.',
      dietaryFocus: 'Whole-food balanced plate with adequate hydration, quality lean proteins, and fiber.',
      stressResponse: 'Standard circadian stress regulation supported by restful 8-hour sleep.',
      clinicalRecommendations: [
        'Consider getting a simple clinical blood typing panel to unlock personalized insights.',
        'Follow standard WHO guideline of 10,000 steps and 2,000 ml water daily.',
        'Maintain a balanced macronutrient distribution.',
      ],
    );
  }
}
