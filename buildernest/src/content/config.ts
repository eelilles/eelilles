import { defineCollection, z } from 'astro:content';

const plans = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    squareFeet: z.number().optional(),
    bedrooms: z.number().optional(),
    bathrooms: z.number().optional(),
    featured: z.boolean().default(false),
    draft: z.boolean().default(false),
    pubDate: z.coerce.date().optional(),
    updatedDate: z.coerce.date().optional(),
    image: z.string().optional(),
    tags: z.array(z.string()).default([])
  })
});

const modules = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.string().optional(),
    order: z.number().default(0),
    draft: z.boolean().default(false),
    pubDate: z.coerce.date().optional(),
    updatedDate: z.coerce.date().optional(),
    image: z.string().optional(),
    tags: z.array(z.string()).default([])
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
