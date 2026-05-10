import asyncio
import aiohttp
import aiofiles
import os
import config
import sys

BASE_URL = "http://api.e-stat.go.jp/rest/3.0/app/getSimpleStatsData"

TYPE_COUNT = 2
CATEGORY_COUNT = 13

REQUIRED_COLUMNS = 10

YEAR = sys.argv[1] if len(sys.argv) > 1 else "2026"
OUTPUT_FILE = f"./data/merged-{YEAR}.csv"

CONCURRENCY_LIMIT = 10
BUFFER_SIZE = 2000

EXCLUDES = (
    "#A05203",  # 合計特殊出生率 (指数版)
)


async def writer_worker(queue, output_file):
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    async with aiofiles.open(output_file, mode="w", encoding="utf-8") as out_f:
        while True:
            chunk = await queue.get()
            if chunk is None:
                queue.task_done()
                break

            await out_f.write(chunk)
            queue.task_done()


async def download_and_enqueue(session, stats_data_id, queue, header_event, semaphore):
    params = {
        "appId": config.APP_ID,
        "statsDataId": stats_data_id,
        "cdTime": f"{YEAR}100000",
        "cdAreaFrom": "01000",
        "cdAreaTo": "47000",
        "sectionHeaderFlg": "2",
    }

    async with semaphore:
        try:
            async with session.get(BASE_URL, params=params) as response:
                response.raise_for_status()

                buffer = []
                is_first_line = True

                async for line_bytes in response.content:
                    line = line_bytes.decode("utf-8")

                    if is_first_line:
                        is_first_line = False

                        if not header_event.is_set():
                            headers = line.split(",")
                            if len(headers) > 3:
                                headers[3] = "category"
                                headers[5] = "area"
                                line = ",".join(headers)
                            buffer.append(line)
                            header_event.set()
                        continue

                    columns = line.split(",")
                    if len(columns) < REQUIRED_COLUMNS:
                        continue

                    category_val = columns[3].strip('"\r\n ')
                    if category_val.startswith(EXCLUDES):
                        continue

                    buffer.append(line)

                    if len(buffer) >= BUFFER_SIZE:
                        await queue.put("".join(buffer))
                        buffer.clear()

                if buffer:
                    await queue.put("".join(buffer))

        except Exception as e:
            print(f"Error fetching {stats_data_id}: {e}")


async def main():
    stats_data_ids = [
        f"000001{(i + 1):02d}{(j + 1):02d}"
        for i in range(TYPE_COUNT)
        for j in range(CATEGORY_COUNT)
    ]
    print("Downloading and merging...")

    queue = asyncio.Queue(maxsize=50)
    header_event = asyncio.Event()
    semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)

    writer_task = asyncio.create_task(writer_worker(queue, OUTPUT_FILE))

    connector = aiohttp.TCPConnector(limit=CONCURRENCY_LIMIT)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [
            download_and_enqueue(session, sid, queue, header_event, semaphore)
            for sid in stats_data_ids
        ]

        await asyncio.gather(*tasks)

    await queue.put(None)
    await writer_task

    print("Finished.")


if __name__ == "__main__":
    asyncio.run(main())
