import { defineCollection, z } from 'astro:content';

// Plan types
const planTypeEnum = z.enum(['cabin', 'small_home', 'adu', 'duplex']);

// Foundation options
const foundationEnum = z.enum(['slab', 'crawlspace', 'basement', 'piers']);

// Climate fit options
const climateEnum = z.enum(['coastal', 'interior', 'northern', 'alpine']);

// Resilience tiers
const resilienceEnum = z.enum(['baseline', 'enhanced', 'resilient_plus']);

const plans = defineCollection({
  type: 'content',
  schema: z.object({
    // Basic info
    name: z.string(),
    slug: z.string().optional(),
    summary: z.string().min(100).max(250),

    // Media
    heroImage: z.string().optional(),
    gallery: z.array(z.string()).default([]),

    // Specs
    floorArea: z.number(),
    bedrooms: z.number().min(0).max(6),
    bathrooms: z.number().min(0).max(4),
    stories: z.number().min(1).max(3).default(1),

    // Classification
    planType: planTypeEnum,
    styleTags: z.array(z.string()).default([]),

    // Site requirements
    foundationOptions: z.array(foundationEnum).default(['slab']),
    climateFit: z.array(climateEnum).default(['interior']),

    // Features
    resilienceTier: z.array(resilienceEnum).default(['baseline']),
    offgridFriendly: z.boolean().default(false),

    // Display
    featured: z.boolean().default(false),
    draft: z.boolean().default(false),

    // Related content
    recommendedModules: z.array(z.string()).default([]),

    // Inclusions text
    publicInclusions: z.string().optional(),
    portalInclusions: z.string().optional(),

    // FAQ items
    faq: z.array(z.object({
      question: z.string(),
      answer: z.string()
    })).default([]),

    // Metadata
    pubDate: z.coerce.date().optional(),
    updatedDate: z.coerce.date().optional()
  })
});

const modules = defineCollection({
  type: 'content',
  schema: z.object({
    // Basic info
    name: z.string(),
    slug: z.string().optional(),
    icon: z.string(), // Icon component name (e.g., 'document', 'cube', 'bolt')
    summary: z.string(), // One-line summary

    // Problem/solution framing
    problem: z.string(), // The problem this module solves

    // What's included
    included: z.array(z.string()).default([]),

    // Inputs needed from user
    inputsNeeded: z.array(z.string()).default([]),

    // Outputs/deliverables
    outputs: z.array(z.string()).default([]),

    // Process steps
    processSteps: z.array(z.object({
      step: z.number(),
      title: z.string(),
      description: z.string().optional()
    })).default([]),

    // FAQ items
    faq: z.array(z.object({
      question: z.string(),
      answer: z.string()
    })).default([]),

    // Display order
    order: z.number().default(0),

    // Status
    draft: z.boolean().default(false),
    comingSoon: z.boolean().default(false),

    // Metadata
    pubDate: z.coerce.date().optional(),
    updatedDate: z.coerce.date().optional()
  })
});

const resources = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.string().optional(),
    draft: z.boolean().default(false),
    pubDate: z.coerce.date().optional(),
    updatedDate: z.coerce.date().optional(),
    externalUrl: z.string().url().optional(),
    tags: z.array(z.string()).default([])
  })
});

export const collections = {
  plans,
  modules,
  resources
};

// Export types for use in components
export type PlanType = z.infer<typeof planTypeEnum>;
export type FoundationType = z.infer<typeof foundationEnum>;
export type ClimateType = z.infer<typeof climateEnum>;
export type ResilienceType = z.infer<typeof resilienceEnum>;
